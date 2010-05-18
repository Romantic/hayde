# ---------------------------------------------------------------------------
#
# This mixin adds some helper methods for file manipulation.
#
# ---------------------------------------------------------------------------

module Hayde
  module Utils
   module Files
       def self.included(base)
   
         # File list method adds accessor to specified attributes that behaves like FileList.
         # I can specify attribute and use it like FileList instance to 
         # include and exclude files, iterate throught file collection.
         # 
         # &names - names of attributes
         #
         # Example:
         #
         # class SomeClass
         #   include Hayde::Utils::Files
         #
         #   filelist_attribute :sources
         # end
         #
         # x = SomeClass.new
         # x.sources.include 'lib/**/*.rb'
         # x.sources.exclude 'doc/**/*'
         # x.each do |file|
         #   puts file
         # end
         #
         def base.filelist_attribute(*names)
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
               if files && files.class != FileList
                 files = FileList.new(files)
               end
               instance_variable_set("@#{name}_files", files)
             end
           end
         end
       end
    end
  end
end