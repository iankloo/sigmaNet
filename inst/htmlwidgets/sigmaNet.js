HTMLWidgets.widget({

  name: "sigmaNet",
  type: "output",

  factory: function(el, width, height){
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
        s.graph.read(x.data)
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
