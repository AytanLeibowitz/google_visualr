module GoogleVisualr

  class BaseChart
    include GoogleVisualr::Packages
    include GoogleVisualr::ParamHelpers

    attr_accessor :data_table, :listeners

    def initialize(data_table, options={})
      @data_table = data_table
      send(:options=, options)
      @listeners  = []
    end

    def chart_name
      class_name
    end

    def chart_function_name(element_id)
      "draw_#{element_id.gsub('-', '_')}"
    end

    def options
      @options
    end

    def options=(options)
      @options = stringify_keys!(options)
    end

    def add_listener(event, callback)
      @listeners << { :event => event.to_s, :callback => callback }
    end

    # Generates JavaScript and renders the Google Chart in the final HTML output.
    #
    # Parameters:
    #  *div_id            [Required] The ID of the DIV element that the Google Chart should be rendered in.

    def to_js(element_id)
      js  = "\n<script type='text/javascript'>"
      js << "\n  google.load('visualization','1', {packages: ['#{package_name}']});"
      js << "\n  google.setOnLoadCallback(#{chart_function_name(element_id)});"
      js << "\n  function #{chart_function_name(element_id)}() {"
      js << "\n    #{@data_table.to_js}"
      js << "\n    var chart = new google.visualization.#{chart_name}(document.getElementById('#{element_id}'));"
      js << "\n    var export_chart = document.getElementById('export_chart');"
      js << "\n    google.visualization.events.addListener(chart, 'select', function() { jQuery.fn.bubble_select(chart.getSelection()); });"
      js << "\n    google.visualization.events.addListener(export_chart, 'click', function () { var imgUri = chart.getImageURI(); document.getElementById('chart_image').src = imgUri; });"
      js << "\n    chart.draw(data_table, #{js_parameters(@options)});"
      js << "\n  };"
      js << "\n</script>"
      js
    end
  end

end
