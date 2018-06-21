sigma.classes.graph.addMethod('neighbors', function(nodeId) {
  var k,
      neighbors = {},
      index = this.allNeighborsIndex[nodeId] || {};

  for (k in index)
    neighbors[k] = this.nodesIndex[k];

  return neighbors;
});

HTMLWidgets.widget({

  name: "sigmaNet",
  type: "output",

  factory: function(el, width, height){
    var s = new sigma({
      renderer: {
        container: el.id
      },
    });
    return {
      renderValue: function(x){
        if (HTMLWidgets.shinyMode) { // If in Shiny app
          // Remove previous occurences of plots in the <div>
          sigmaID = document.getElementById(el.id)
          while (sigmaID.firstChild) {
            //The list is LIVE so it will re-index each call
            sigmaID.removeChild(sigmaID.firstChild);
          }
          s = new sigma({
            renderer: {
              container: el.id
            },
          })
          s.refresh();
        }

        s.settings('minEdgeSize', x.options.minEdgeSize);
        s.settings('maxEdgeSize', x.options.maxEdgeSize);
        s.settings('minNodeSize', x.options.minNodeSize);
        s.settings('maxNodeSize', x.options.maxNodeSize);
        s.settings('doubleClickEnabled', x.options.doubleClickZoom);
        s.settings('mouseWheelEnabled', x.options.mouseWheelZoom);
        s.graph.read(x.data);
        if(x.options.neighborEvent != 'None'){
          s.graph.nodes().forEach(function(n) {
            n.originalColor = n.color;
          });
          s.graph.edges().forEach(function(e) {
            e.originalColor = e.color;
            e.type = x.options.edgeArrows;
          });
          s.bind(x.options.neighborStart, function(e) {
            var nodeId = e.data.node.id,
                toKeep = s.graph.neighbors(nodeId);
            toKeep[nodeId] = e.data.node;
            s.graph.nodes().forEach(function(n) {
              if (toKeep[n.id])
                n.color = n.originalColor;
              else
                n.color = '#eee';
            });
            s.graph.edges().forEach(function(e) {
              if (toKeep[e.source] && toKeep[e.target])
                e.color = e.originalColor;
              else
                e.color = '#eee';
            });
            s.refresh();
          });
          s.bind(x.options.neighborEnd, function(e) {
            s.graph.nodes().forEach(function(n) {
              n.color = n.originalColor;
            });
            s.graph.edges().forEach(function(e) {
              e.color = e.originalColor;
            });
            s.refresh();
          });

          if(HTMLWidgets.shinyMode){
            if(x.options.sigmaEvents){
              if(x.options.sigmaEvents == 'clickNode'){
                s.bind("clickNode", function(d){
                  Shiny.onInputChange('node_data', d.data.node)
                })
              }
              if(x.options.sigmaEvents == 'hoverNode'){
                s.bind("overNode", function(d){
                  Shiny.onInputChange('node_data', d.data.node)
                })
              }
            }
          }
        }
        s.refresh();
      },
      resize: function(width, height){
        for(var name in s.renderers)
          s.renderers[name].resize(width, height);
      },
      s: s
    };
  }
})
