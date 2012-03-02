This gem ads simple helpers to [Middleman](http://middlemanapp.com) static site generator 
to add navigation menus and breadcrumbs.

# Installation

1. add the gem in your Gemfile:

        gem "middleman-navigation", :git=>"git://github.com/multiscan/middleman-navigation.git"

2. run bundler

        bundle install

3. include it in your config.rb file

        require middleman-navigation

        activate :navigation

# Usage
  
The gem adds two helper functions to middleman: children_nav and trail_nav

## children_nav

Creates a list of links to the pages that are direct descendant of the current one. All source files with an underscore as first or last character of the file name and directories beginning with underscore, are excluded from the list.

Example:
    =children_nav 'main'


### Page options 
The behaviour of children_nav can be changed by adding a metadata at head of source files.

Example:

      ---
      nonav: true
      weight: 80
      menu_title: Custom Title
      menu_scope: main
      ---
      Here you have the actual page source


*nonav*: option inhibits the creation of the menu for the current page
*weight*: is used to alter the order of the links in the navigation menu
*menu_title*: is used to set a custom title to menu, default to file name.
*menu_scope*: the name of menu that will handle this link

## trail_nav

This create a list of links from the root page to the current node.

## Example ##

Your template might look like the following:

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

# Problems

* Current version only works with haml source files.
* No nested navigation yet 
* Not yet compatible with :directory_indexes feature

