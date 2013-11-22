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

## Model, View and Controller

See the article [here](http://www.codeproject.com/Articles/685326/A-PropertyGrid-implemented-in-Ruby-on-Rails) for
how to create your model, view, and controller.

### A Basic Model

This is the model I used in the demo:

```
# A class that behaves like an ActiveRecord, so we can use it in form_for, but isn't actually persisted.
class NonPersistedActiveRecord
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  # Required by ActiveModel::Naming to tell it we're not persisting the model.
  def persisted?
    false
  end
end

class PropertyGridRecord < NonPersistedActiveRecord
  attr_accessor :prop_a
  attr_accessor :prop_b
  attr_accessor :prop_c
  attr_accessor :prop_d
  attr_accessor :prop_e
  attr_accessor :prop_f
  attr_accessor :prop_g
  attr_accessor :prop_h
  attr_accessor :prop_i
  attr_accessor :records

  def initialize
    @records =
        [
            ARecord.new(1, 'California'),
            ARecord.new(2, 'New York'),
            ARecord.new(3, 'Rhode Island'),
        ]

    @prop_a = 'Hello World'
    @prop_b = 'Password!'
    @prop_c = '08/19/1962'
    @prop_d = '12:32 pm'
    @prop_e = '08/19/1962 12:32 pm'
    @prop_f = true
    @prop_g = '#ff0000'
    @prop_h = 'Pears'
    @prop_i = 2
  end
end
```
You'll note in this particular case I'm spoofing using an ActiveRecord -- you can of course
use ActiveRecord models as well.

### A Basic View

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

### A Basic Controller

Here's an example of how the controller puts it all together.  You'll see this code in the demo as well.

```
include PropertyGrid

class DemoPageController < ApplicationController
  def index
    initialize_attributes
  end

  private

  def initialize_attributes
    @property_grid_record = PropertyGridRecord.new
    @property_grid = define_property_grid
    @javascript = generate_javascript_for_property_groups(@property_grid)
  end

  def define_property_grid
    grid = new_property_grid
    group 'Text Input'
    group_property 'Text', :prop_a
    group_property 'Password', :prop_b, :password
    group 'Date and Time Pickers'
    group_property 'Date', :prop_c, :date
    group_property 'Time', :prop_d, :date
    group_property 'Date/Time', :prop_e, :datetime
    group 'State'
    group_property 'Boolean', :prop_f, :boolean
    group 'Miscellaneous'
    group_property 'Color', :prop_g, :color
    group 'Lists'
    group_property 'Basic List', :prop_h, :list, ['Apples', 'Oranges', 'Pears']
    group_property 'ID - Name List', :prop_i, :db_list, @property_grid_record.records

    grid
  end
end
```

