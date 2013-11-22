property_grid
=============

![screenshot](http://www.codeproject.com/KB/user-controls/685326/screenshot.png)

# Description

PropertyGrid is a gem containing the classes and helper functions for the server-side Property Grid control.
A demo of this control can be found [here](https://github.com/cliftonm/property_grid_demo) and an article documenting
how the property grid works is [here](http://www.codeproject.com/Articles/685326/A-PropertyGrid-implemented-in-Ruby-on-Rails).

# Features

* Programmatically define groups and properties within groups
* The property grid is generated at runtime on the server-side based on run-time definitions
* Define the groups and properties with a fluid programming style
* Alternatively, define the groups and properties with a minimal DSL
* Take advantage of jQuery UI and/or other extensions for custom web controls
* Easily define properties based on type and extend types with custom web controls
* Easily extend all functionality using derived classes

# How To Start

```
gem install property_grid
```

The gem by default uses jQuery UI for the date/time pickers and the color picker, so to take advantage of these
web controls, you will need to specify in your gemfile:

```
gem 'jquery-ui-sass-rails'
gem 'jquery_datepicker'
gem 'jquery-minicolors-rails'
```

The demo code utilizes CSS/HTMLmarkup in SASS and Slim respectively, which require:

```
gem 'slim'
gem 'sass'
```

## Define Your CSS

This is an example of the SASS that is used in the [demo](https://github.com/cliftonm/property_grid_demo)

```
.property_grid
  background-color: #0000FF
  width: 400px
  float: left
  border: 1px solid
  border-color: #000000
  ul
    margin: 0 0 0 0
    padding: 0 0 0 0
  li.expanded
    background: url(/assets/up.png) no-repeat
    background-position: 0px 4px
    list-style-type: none
    background-color: #0000FF
    color: #ffffff
    padding-left: 20px
    padding-top: 2px
    padding-bottom: 3px
    height: 16px
  li.collapsed
    background: url(/assets/down.png) no-repeat
    background-position: 0px 1px
    list-style-type: none
    background-color: #0000FF
    color: #ffffff
    padding-left: 20px
    padding-top: 2px
    padding-bottom: 3px
    height: 16px
  .property_group
    width: 100%
    table
      font-family: Verdana, Arial, sans-serif
      line-height: 1.5em
      font-size: 10pt
      border-collapse: collapse
      margin-left: 10px
      table-layout: fixed
      th
        padding-left: 5px
        padding-right: 5px
        text-align: left
      td
        padding-left: 5px
        padding-right: 5px
        width: 1%
      td.last                                  // the last column fills any remaining space
        width: 1%
        input
          width: 100%
        select
          width: 100%
      tr                                       // the header row
        background-color: #e0e0ff
```

##

This is the basic structure of the markup in Slim syntax.

```
=fields_for @property_grid_record do |f|
  .property_grid
    ul
      - @property_grid.groups.each_with_index do |group, index|
        li.expanded class="expandableGroup#{index}" = group.name
        .property_group
          div class="property_group#{index}"
            table
              tr
                th Property
                th Value
              - group.properties.each do |prop|
                tr
                  td
                    = prop.property_name
                  td.last
                    - # must be processed here so that ERB has the context (the 'self') of the HTML pre-processor.
                    = render inline: ERB.new(prop.get_input_control).result(binding)

  = javascript_tag @javascript

  javascript:
      $(".jq_dateTimePicker").datetimepicker({dateFormat: 'mm/dd/yy', timeFormat: 'hh:mm tt'});
      $(".jq_timePicker").timepicker({timeFormat: "hh:mm tt"});
      $(".jq_colorPicker").minicolors()
```

## Model, View and Controller

See the article [here](http://www.codeproject.com/Articles/685326/A-PropertyGrid-implemented-in-Ruby-on-Rails) for
how to create your model, view, and controller.
