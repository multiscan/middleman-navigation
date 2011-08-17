This gem ads simple helpers to [Middleman](http://middlemanapp.com) static site generator.

# Installation

1. add the gem in your Gemfile:
    gem "middleman-navigation"
2. run bundler
    bundle install
3. include it in your config.rb file
    require middleman-navigation'
    activate :navigation

# Usage
  
The gem adds two helper functions to middleman: children_nav and trail_nav

## children_nav

Creates a list of links to the pages that are direct descendant of the current one.
The behaviour can be changed by adding a *weight* and/or a *nonav* option in 
the page front matter. Example:
      ---
      nonav: true
      weight: 80
      ---
      Here you have the actual page source

The *nonav* option inhibits the creation of the menu for the current page while
*weight* is used to alter the order of the links in the navigation menu. The higher
the weight, the earlier the link.

## trail_nav

This create a list of links from the root page to the current node.

## Example ##

Your template might look like the following:

<code>
      !!! 5
      %html{ :lang => "en" }
        %head
          %meta{ :charset => "utf-8" }    
          = stylesheet_link_tag "site.css"
          :javascript
          = favicon_tag "/images/favicon.png"
          = yield_content :head
        %body{ :class => page_classes }
          %header
            %hgroup{:id=>'breadcrumbs'}
              = trail_nav
            %nav{:id=>'nav'}=children_nav
          #content
            = yield
</code>
