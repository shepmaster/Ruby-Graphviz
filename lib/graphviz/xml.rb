# Copyright (C) 2004, 2005, 2006, 2007, 2008, 2009, 2010 Gregoire Lejeune <gregoire.lejeune@free.fr>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA

require 'graphviz'
require 'rexml/document'

class GraphViz
  class XML
    
    # The GraphViz object
    attr_accessor :graph
    
    # 
    # Generate the graph
    # 
    # THIS METHOD IS DEPRECATED, PLEASE USE GraphViz::XML.graph.output
    # 
    def output( *options )
      warn "GraphViz::XML.output is deprecated, use GraphViz::XML.graph.output"
      @graph.output( *options )
    end
    
    private
    
    # 
    # Create a graph from a XML file
    # 
    # In:
    # * xml_file : XML File
    # * *options : Graph options:
    #   * :text : show text nodes (default true)
    #   * :attrs : show XML attributs (default true)
    # 
    def initialize( xml_file, *options )
      @node_name = "00000"
	   @show_text = true
	   @show_attributs = true

      if options.nil? == false and options[0].nil? == false
        options[0].each do |xKey, xValue|
          case xKey.to_s
            when "text"
              @show_text = xValue
		          options[0].delete( xKey )
            when "attrs"
              @show_attributs = xValue
		          options[0].delete( xKey )
          end
        end
      end

      @rexml_document = REXML::Document::new( File::new( xml_file ) )
      @graph = GraphViz::new( "XML", *options ) 
      parse_xml_node( @rexml_document.root() )
    end
    
    def parse_xml_node( xml_node ) #:nodoc:
      local_node_name = @node_name.clone
      @node_name.succ!
      
      label = xml_node.name
      if xml_node.has_attributes? == true and @show_attributs == true
        label = "{ " + xml_node.name 
		
		    xml_node.attributes.each do |xName, xValue|
		      label << "| { #{xName} | #{xValue} } " 
		    end
		
		    label << "}"
	    end
      @graph.add_nodes( local_node_name, "label" => label, "color" => "blue", "shape" => "record" )

      ## Act: Search and add Text nodes
      if xml_node.has_text? == true and @show_text == true
        text_node_name = local_node_name.clone
        text_node_name << "111"
        
        xText = ""
        xSep = ""
        xml_node.texts().each do |l|
          x = l.value.chomp.strip
          if x.length > 0
            xText << xSep << x
            xSep = "\n"
          end
        end

        if xText.length > 0
          @graph.add_nodes( text_node_name, "label" => xText, "color" => "black", "shape" => "ellipse" )
          @graph.add_edges( local_node_name, text_node_name )
        end
      end

      ## Act: Search and add attributs
      ## TODO

      xml_node.each_element( ) do |xml_child_node|
        child_node_name = parse_xml_node( xml_child_node )
        @graph.add_edges( local_node_name, child_node_name )
      end

      return( local_node_name )
    end

  end
end
