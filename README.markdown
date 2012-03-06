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
The gem add a menu helper to Middleman.

## menu

Automatic generate menu reading pages at project root folder.

Example:
    =menu 'main' [, [options]]


### Metadata
The behaviour of menu can be changed by adding a metadata at head of source files.

Example:
      ---
      nonav: true
      weight: 80
      menu_title: Custom Title
      menu_scope: main
      ---
      Here you have the actual page source

*nonav*: option inhibits the creation of the menu for the current page
*hidden*: option explicitly remove the current page from it's parent menu. By default all pages with an underscore in the beginning or end of their source file name are hidden; 
*weight*: is used to alter the order of the links in the navigation menu (the smaller the weight, the earlier the page will be listed *NOTE: this is the opposite of what the plugin used to do*);
*menu_title*: is used to set a custom title to menu, default to file name;
*menu_scope*: the name of menu that will handle this link

# Problems

* Files ext must be .html.haml (Need fix it);
* Dont search files for generate menu on children folder;
* Current version only works with haml source files;
* No nested navigation yet;
* Not yet compatible with :directory_indexes feature.