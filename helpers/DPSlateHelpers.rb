
module DPSlateHelpers
  require 'pathname'
  require 'pp'
#
# build_toc - routine to build a static toc using HTML
# inputs
#   page_content - the HTML for the page as a single string
#   tocSelectors - string of comma values header tags that should be in the index, e.g., "h1,h2,h3"
# outputs
#   string that contains the HTML for the table of contents
#   
  def build_toc(page_content, tocSelectors)
    html_doc = Nokogiri::HTML::DocumentFragment.parse(page_content)     # parse the HTML generated by the Markdown
    tocContent = '<ul class="nav submenu-1" id="nav">'
    prevLevel = 0
    html_doc.css(tocSelectors).each do |header|                         # Loop through the required headers
      currLevel = header.name[1].to_i
      if prevLevel == 0
          prevLevel = currLevel
      end
      if prevLevel > currLevel
        for i in (currLevel..(prevLevel-1))
            tocContent += ' </ul></li>'
        end
      end
      if prevLevel == currLevel
          tocContent += ' </li>'
      end
      if prevLevel < currLevel
          tocContent += ' <ul class="toc-submenu-' + currLevel.to_s + ' nav">'
      end
      tocContent += ' <li class="toc-' + header.name + '"> <a href="#' + header.attribute('id') + '" class="toc-' + header.name + '"> ' + header.content + ' </a>'
      prevLevel = currLevel
    end
    tocContent += ' </ul>'
    return tocContent
  end  
    
#
# datestring() - routine to return the current time as a formatted date string
# input - none
# output
#   string that contains a formatted version of the current date and time of the system
#    
  def datestring()
    Time.now.strftime('%B %d, %Y at %H:%M %Z')
  end

#
# hash_to_yaml (hash) - routine to convert a ruby hash to a YAML string
# input 
#   hash - the hash that is to be converted
# output
#   string that contains a YAML version of the hash
#  
  def hash_to_yaml (hash) 
      return "<pre> " + PP.pp(hash, "") + "</pre>"
  end    
    
#
# get_defaults() - routine to get and merge the values of the _default.yml files along the directory path
# inputs
#   dirspec - the directory spec of the leaf folder to be used to look for the _defaults.yml files
# outputs
#   a ruby hash that contains the defaults for the page directives it can also include any user defined variables
#
    
  def get_defaults ( dirspec ) 
      if (dirspec == "." or dirspec == "/")
        noDefaults = {
          "title" => "",
          "version" => "",
          "copyright" => "",
          "publisher" => "",
          "publisherAddress" => "",
          "comments" => "",
          "tableOfContents" => true,
          "tocAccordion" => 1,
          "rightPanel" => true,
          "leftPanel" => true,
          "documentSearch" => true,
          "languageTabs" => [ { 'default' => 'Default' } ],
          "tocSelectors" => "h1,h2,h3",
          "tocFooters" => []
        }
        return noDefaults
      else
        this_defaults = read_defaults (dirspec + "/_defaults.yml")
        return get_defaults(Pathname.new(dirspec).parent.to_s).update(this_defaults)    
      end 
  end
    
#
# read_defaults() - routine to read the _default.yml files
# inputs
#   filespec - the filespec for the _defaults.yml files
# outputs
#   a ruby hash that contains the defaults read from the filespec, if the file is not found, then an empty has is returned
#    

  def read_defaults (filespec)
      if File.exists? ( filespec)
        return defaults = YAML.load_file(filespec)
      else
        return defaults = {}
      end  
  end


#
# add_sections() - routine to add section tags (page breaks) wherever there is a <p></p> with a string that contains "+++"
# inputs
#   document - the html output from the page
# outputs
#   document - the html output 
#    

  def add_sections (document)
    return "<section>" + document.gsub(/\<p\>\+\+\+.*\n\<\/p\>/,"</section><section>") + "</section>"
  end  

end 

