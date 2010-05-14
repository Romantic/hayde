# ---------------------------------------------------------------------------
#
# This script generates the guides. It can be invoked either directly or via the
# generate_guides rake task within the railties directory.
#
# Guides are taken from the source directory, and the resulting HTML goes into the
# output directory. Assets are stored under files, and copied to output/files as
# part of the generation process.
#
# Options:
#
#   :warnings
#     If you are writing a guide, please work always with :warnings = true. 
#     Users can generate the guides, and thus this flag is off by default.
#
#     Internal links (anchors) are checked. If a reference is broken levenshtein
#     distance is used to suggest an existing one. This is useful since IDs are
#     generated by Textile from headers and thus edits alter them.
#
#     Also detects duplicated IDs. They happen if there are headers with the same
#     text. Please do resolve them, if any, so guides are valid XHTML.
#
#   :force
#    Set to true to force the generation of all guides.
#
#   :edge
#     Set to true to indicate generated guides should be marked as edge. This
#     inserts a badge and changes the preamble of the home page.
#
#   :layout
#     Use to customize layout. Layout must be placed to the same directory with guides sources.
#
# ---------------------------------------------------------------------------

require 'set'
require 'fileutils'

require 'active_support/core_ext/string/output_safety'
require 'active_support/core_ext/object/blank'
require 'action_controller'
require 'action_view'

require 'hayde/indexer'
require 'hayde/helpers'
require 'hayde/levenshtein'

module Hayde
  class Generator    
    # TODO: Move method to utils mudule.
    def self.filelist_attribute(*names)
      names.each do |name|
        define_method "#{name}" do
          files = instance_variable_get("@#{name}_files")
          if !files
            files = FileList.new()
            instance_variable_set("@#{name}_files", files)
          end
          files
        end

        define_method "#{name}=" do |files|
          instance_variable_set("@#{name}_files", FileList[files])
          if files && files.class != FileList
              files = FileList.new(files)
          end
        end
      end
    end
    
    attr_accessor :output_dir, :assets_dir, :warnings, :edge, :force, :layout    
    filelist_attribute :sources

    GUIDES_RE = /\.(?:textile|html\.erb)$/

    def initialize(output = nil)
      initialize_output_dir(output)
      yield self if block_given?
    end

    def generate
      generate_guides
      copy_assets
    end

    private
    
    def initialize_output_dir(output)
      @output_dir = output || File.join(File.dirname(__FILE__), "docs", "guides")
      FileUtils.mkdir_p(@output_dir)
    end

    def generate_guides
      sources.each do |source|
        output = output_file_for(source)
        generate_guide(source, output) if generate?(source, output)
      end
    end

    def copy_assets
      FileUtils.cp_r(Dir.glob("#{assets_dir}/*"), output_dir)
    end

    def output_file_for(source)
      output = File.basename(source).sub(GUIDES_RE, '.html')
      File.join(output_dir, output)
    end
    
    def generate?(source, output)
      force || !File.exists?(output) || File.mtime(output) < File.mtime(source)
    end

    def generate_guide(source, output)
      puts "Generating #{output}"
      File.open(output, 'w') do |f|
        view = ActionView::Base.new(File.dirname(source), :edge => edge)
        view.extend(Helpers)

        if source =~ /\.html\.erb$/
          # Generate the special pages like the home.
          result = view.render(:layout => 'layout', :file => source)
        else
          body = File.read(source)
          body = set_header_section(body, view)
          body = set_index(body, view)

          result = view.render(:layout => 'layout', :text => textile(body))

          warn_about_broken_links(result) if warnings
        end

        f.write result
      end
    end

    def set_header_section(body, view)
      new_body = body.gsub(/(.*?)endprologue\./m, '').strip
      header = $1

      header =~ /h2\.(.*)/
      page_title = "Framework Guides: #{$1.strip}"

      header = textile(header)

      view.content_for(:page_title) { page_title.html_safe }
      view.content_for(:header_section) { header.html_safe }
      new_body
    end

    def set_index(body, view)
      index = <<-INDEX
      <div id="subCol">
        <h3 class="chapter"><img src="images/chapters_icon.gif" alt="" />Chapters</h3>
        <ol class="chapters">
      INDEX

      i = Indexer.new(body, warnings)
      i.index

      # Set index for 2 levels
      i.level_hash.each do |key, value|
        link = view.content_tag(:a, :href => key[:id]) { textile(key[:title], true).html_safe }

        children = value.keys.map do |k|
          view.content_tag(:li,
            view.content_tag(:a, :href => k[:id]) { textile(k[:title], true).html_safe })
        end

        children_ul = children.empty? ? "" : view.content_tag(:ul, children.join(" ").html_safe)

        index << view.content_tag(:li, link.html_safe + children_ul.html_safe)
      end

      index << '</ol>'
      index << '</div>'

      view.content_for(:index_section) { index.html_safe }

      i.result
    end

    def textile(body, lite_mode=false)
      # If the issue with notextile is fixed just remove the wrapper.
      with_workaround_for_notextile(body) do |body|
        t = RedCloth.new(body)
        t.hard_breaks = false
        t.lite_mode = lite_mode
        t.to_html(:notestuff, :plusplus, :code, :tip)
      end
    end

    # For some reason the notextile tag does not always turn off textile. See
    # LH ticket of the security guide (#7). As a temporary workaround we deal
    # with code blocks by hand.
    def with_workaround_for_notextile(body)
      code_blocks = []
      body.gsub!(%r{<(yaml|shell|ruby|erb|html|sql|plain)>(.*?)</\1>}m) do |m|
        es = ERB::Util.h($2)
        css_class = ['erb', 'shell'].include?($1) ? 'html' : $1
        code_blocks << %{<div class="code_container"><code class="#{css_class}">#{es}</code></div>}
        "\ndirty_workaround_for_notextile_#{code_blocks.size - 1}\n"
      end
      
      body = yield body
      
      body.gsub(%r{<p>dirty_workaround_for_notextile_(\d+)</p>}) do |_|
        code_blocks[$1.to_i]
      end
    end

    def warn_about_broken_links(html)
      anchors = extract_anchors(html)
      check_fragment_identifiers(html, anchors)
    end
    
    def extract_anchors(html)
      # Textile generates headers with IDs computed from titles.
      anchors = Set.new
      html.scan(/<h\d\s+id="([^"]+)/).flatten.each do |anchor|
        if anchors.member?(anchor)
          puts "*** DUPLICATE ID: #{anchor}, please put and explicit ID, e.g. h4(#explicit-id), or consider rewording"
        else
          anchors << anchor
        end
      end

      # Also, footnotes are rendered as paragraphs this way.
      anchors += Set.new(html.scan(/<p\s+class="footnote"\s+id="([^"]+)/).flatten)
      return anchors
    end
    
    def check_fragment_identifiers(html, anchors)
      html.scan(/<a\s+href="#([^"]+)/).flatten.each do |fragment_identifier|
        next if fragment_identifier == 'mainCol' # in layout, jumps to some DIV
        unless anchors.member?(fragment_identifier)
          guess = anchors.min { |a, b|
            Levenshtein.distance(fragment_identifier, a) <=> Levenshtein.distance(fragment_identifier, b)
          }
          puts "*** BROKEN LINK: ##{fragment_identifier}, perhaps you meant ##{guess}."
        end
      end
    end
  end
end
