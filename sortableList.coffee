# SortableList Module
# Developed by Russ Campbell
# 12/18/2017

class SortableList extends ScrollComponent
  constructor: (options={}) ->
    super _.defaults options,
            spacing: 10
            sortSpread: 20
            width: 300
            height: 500
            listMargins: 0
            layerShadowBlur: 0
            backgroundColor: "pink"
            scrollHorizontal: false
            mouseWheelEnabled: true
            backgroundColor: "pink"
            clip: true
    
    sc = @
    
    # Sorting Variables
    drugItem = null
    previousShadowBlur = 0
    itemHoverIndex = null
    spreadAtIndex = null
    
    # Pass clip setting to content
    sc.content.clip = options.clip
    sc.contentInset.top = options.spacing
    
    # Sorting Functions
    updateLayerPositions = (spreadAtIndex) ->
      # Positions layers based on displayIndex property. A null displayIndex won't be positioned.
      for g in sc.content.children
        if g.displayIndex != null
          spread = if spreadAtIndex != null and g.displayIndex >= spreadAtIndex then options.sortSpread else 0
          g.animate
            x: options.listMargins
            y: spread + (g.displayIndex*(g.height + options.spacing))
            options:
              time: .25
    
    addLayerAtIndex = (layer, index) ->
      layer.parent = sc.content
      layer.listIndex = i
      layer.displayIndex = i
      layer.x = options.listMargins
      layer.y = i*(layer.height + options.spacing)
      layer.draggable = true
      layer.shadowBlur = options.shadowBlur
      layer.width = sc.width - (options.listMargins*2)
      
      # Drag Start
      layer.on Events.DragStart, (event,layer) ->
        drugItem = layer
        previousShadowBlur = layer.style.shadowBlur
        sc.scroll = false
        layer.bringToFront()
        sc.bringToFront()
    
        # Remove layer from positioning
        for i in sc.content.children
          if i.displayIndex > layer.displayIndex then i.displayIndex = i.displayIndex - 1
        layer.displayIndex = null
        updateLayerPositions()
        
        layer.animate
          shadowColor: "rgba(0,0,0,0.2)"
          shadowBlur: 32
          scale: 1.05
          opacity: .6
          options:
            curve: "spring(600,50,0)"
            time: 0.4
      
      # Drag Move
      layer.on Events.DragMove, (event,layer) ->
        touchY =  layer.y + (layer.height/2)
        tIndex = Math.round(touchY / (layer.height + options.spacing))
        if itemHoverIndex != tIndex
          itemHoverIndex = tIndex
          updateLayerPositions(itemHoverIndex)
      
      # Drag End
      layer.on Events.DragEnd, (event,layer) ->
        sc.scroll = true
        drugItem = null
        
        sortedLayers = sc.content.children.sort (a,b) ->
          return if a.y >= b.y then 1 else -1
          
        for i in [0..sortedLayers.length - 1]
          sortedLayers[i].listIndex = i
          sortedLayers[i].displayIndex = i
          
        layer.animate
          shadowColor: "rgba(0,0,0,0.2)"
          shadowBlur: options.layerShadowBlur
          scale: 1
          opacity: 1
          options:
            curve: "spring(600,50,0)"
            time: 0.4
        updateLayerPositions()
    
    #Add layers to content
    for i in [0..options.list.length - 1]
      addLayerAtIndex(options.list[i], i)
      
    module.exports = SortableList
