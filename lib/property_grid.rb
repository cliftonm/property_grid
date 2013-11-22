require "property_grid/version"

module PropertyGrid
  class PropertyGridTypes
    def self.get_property_type_map
      {
          string: ControlType.new('text_field'),
          text: ControlType.new('text_area'),
          boolean: ControlType.new('check_box'),
          password: ControlType.new('password_field'),
          date: ControlType.new('datepicker'),
          datetime: ControlType.new('text_field', 'jq_dateTimePicker'),
          time: ControlType.new('text_field', 'jq_timePicker'),
          color: ControlType.new('text_field', 'jq_colorPicker'),
          list: ControlType.new('select'),
          db_list: ControlType.new('select')
      }
    end
  end

  # A container mapping types to control classes
  class ControlType
    attr_accessor :type_name
    attr_accessor :class_name

    def initialize(type_name, class_name = nil)
      @type_name = type_name
      @class_name = class_name
    end
  end

  # Defines a PropertyGrid group
  # A group has a name and a collection of properties.
  class PropertyGridGroup
    attr_accessor :name
    attr_accessor :properties

    def initialize
      @name = nil
      @properties = []
    end

    # Adds a property to the properties collection and returns self.
    def add_property(var, name, property_type = :string, collection = nil)
      group_property = GroupProperty.new(var, name, property_type, collection)
      @properties << group_property
      self
    end
  end

  # A container for a property within a group.
  class GroupProperty
    attr_accessor :property_var
    attr_accessor :property_name
    attr_accessor :property_type
    attr_accessor :property_collection

    # some of these use jquery: http://jqueryui.com/
    def initialize(var, name, property_type, collection = nil)
      @property_var = var
      @property_name = name
      @property_type = property_type
      @property_collection = collection
    end

    # returns the ERB for this property as defined by its property_type
    def get_input_control
      form_type = PropertyGridTypes.get_property_type_map[@property_type]
      raise "Property '#{@property_type}' is not mapped to an input control" if form_type.nil?
      erb = get_erb(form_type)

      erb
    end

    # Returns the erb for a given form type.  This code handles the construction of the web control that will display
    # the content of a property in the property grid.
    # The web page must utilize a field_for ... |f| for this construction to work.
    def get_erb(form_type)
      erb = "<%= f.#{form_type.type_name} :#{@property_var}"
      erb << ", class: '#{form_type.class_name}'" if form_type.class_name.present?
      erb << ", #{@property_collection}" if @property_collection.present? && @property_type == :list
      erb << ", options_from_collection_for_select(f.object.records, :id, :name, f.object.#{@property_var})" if @property_collection.present? && @property_type == :db_list
      erb << "%>"

      erb
    end

  end

# Class defining the property grid
# A property grid consists of property groups, and groups contain properties.
  class APropertyGrid
    attr_accessor :groups

    def initialize
      @groups = []
    end

    # Give a group name, creates a group, yielding to a block that can be used
    # to define properties within the group, and returning self so that additional
    # groups can be added in a fluid code style.
    def add_group(name)
      group = PropertyGridGroup.new
      group.name = name
      @groups << group
      yield(group)          # yields to block creating group properties
      self                  # returns the PropertyGrid instance
    end
  end

  # ********************************** DSL functions

  def new_property_grid(name = nil)
    @__property_grid = APropertyGrid.new

    @__property_grid
  end

  def group(name)
    group = PropertyGridGroup.new
    group.name = name
    @__property_grid.groups << group

    group
  end

  def group_property(name, var, type = :string, collection = nil)
    group_property = GroupProperty.new(var, name, type, collection)
    @__property_grid.groups.last.properties << group_property

    group_property
  end

  # ********************************** Helper functions

  def generate_javascript_for_property_groups(grid)
    javascript = ''

    grid.groups.each_with_index do |grp, index|
      javascript << get_javascript_for_group(index)
    end

    javascript
  end

  def get_javascript_for_group(index)
    js = %Q|
      $(".expandableGroup[idx]").click(function()
      {
        var hidden = $(".property_group[idx]").is(":hidden");       // get the value BEFORE making the slideToggle call.
        $(".property_group[idx]").slideToggle('slow');

                                                                    // At this point,  $(".property_group0").is(":hidden");
                                                                    // ALWAYS RETURNS FALSE

        if (!hidden)                                                // Remember, this is state that the div WAS in.
        {
          $(".expandableGroup[idx]").removeClass('expanded');
          $(".expandableGroup[idx]").addClass('collapsed');
        }
        else
        {
          $(".expandableGroup[idx]").removeClass('collapsed');
          $(".expandableGroup[idx]").addClass('expanded');
        }
      });
    |.gsub('[idx]', index.to_s)

    js
  end
end
