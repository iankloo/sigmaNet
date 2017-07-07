HTMLWidgets.widget({

  name: "sigmaNet",
  type: "output",

  factory: function(el, width, height){
    //console.log(x)
    var s = new sigma({
      renderer: {
        container: el.id
      },
      settings:{
        defaultNodeColor: "#3182bd",
        defaultEdgeColor: "#636363",
        edgeColor: 'default',
        minEdgeSize: .05,
        maxEdgeSize: .05
      }
    });
    return {
      renderValue: function(x){

        s.settings('minEdgeSize', x.options.minEdgeSize);
        s.settings('maxEdgeSize', x.options.maxEdgeSize);
        s.settings('defaultNodeColor', x.options.nodeColor);
        s.settings('defaultEdgeColor', x.options.edgeColor);
        s.settings('minNodeSize', x.options.minNodeSize);
        s.settings('maxNodeSize', x.options.maxNodeSize);


        s.graph.read(x.data);
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
