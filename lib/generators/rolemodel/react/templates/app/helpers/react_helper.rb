module ReactHelper
  def react_component(component_name, props = {})
    tag.div(
      data: {
        controller: 'react',
        component: component_name,
        props: props.to_json
      }
    )
  end
end
