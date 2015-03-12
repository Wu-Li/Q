function asIdea(list) {
    root = MAPJS.content({"title":list.title});
    if(list.title=='') return root;
    function addIdeas(id,ideas) {
        for(key in ideas) {
            if(isNaN(parseInt(key))) kid = root.addSubIdea(id,key);
            else kid = id;
            if(typeof(ideas[key]) != 'object'){
                root.addSubIdea(kid,ideas[key].toString());       
            } else {
                for(k in ideas[key]){
                    addIdeas(kid,ideas[key]);
                }
            }
        }
        kid = null;
        id = null;
        ideas = null;
    }
    addIdeas(1,list.children);
    return root;
}

var imageInsertController = new MAPJS.ImageInsertController("http://localhost:4999?u=");
function buildMap(container,mapJSON) {
  m = JSON.stringify(mapJSON);  
  m = m.replace(/&amp;/g,'&').replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&#46;/g,'.');
  mapJSON = JSON.parse(m);
  
  if(mapJSON.hasOwnProperty('children')) var idea = asIdea(mapJSON);    
  else var idea = MAPJS.content(mapJSON);
  
  var mapModel = new MAPJS.MapModel(MAPJS.DOMRender.layoutCalculator, []);
  mapModel.id = container.attr('id');
  container.domMapWidget(console, mapModel, false, imageInsertController);
  mapModel.setIdea(idea);
  return mapModel;
};

var mapBinding = new Shiny.InputBinding();
$.extend(mapBinding, {
  find: function(scope) { return $(".qmap"); },
  getType: function(el) {
    return "Q.mapBinding" ;
  },
  hasGrandChildren: function(idea) {
    var subIdeas = idea.sortedSubIdeas();
    var gc = false;
    subIdeas.forEach(function(childIdea) {
      if(childIdea.sortedSubIdeas().length > 0) {
        gc = true;
      }
    });
    return gc;
  },
  getNode: function (idea) {
    var subIdeas = idea.sortedSubIdeas();
    if (subIdeas.length == 0) { 
        var node = idea.title;
    } else if (subIdeas.length == 1) {
        var node = {};
        subIdeas.forEach(function(childIdea) {
          node[idea.title] = mapBinding.getNode(childIdea);
        });
    } else if (!(mapBinding.hasGrandChildren(idea))) {
        var node = {};
        node[idea.title] = [];
        subIdeas.forEach(function(childIdea) {
          node[idea.title].push(mapBinding.getNode(childIdea));
        });
    } else {
        var node = {};
        var values = [];
        node[idea.title] = {};
        subIdeas.forEach(function(childIdea) {
            var childNode = mapBinding.getNode(childIdea);
            if (typeof(childNode) == 'string') {
                var v = Number(childNode);
                if(isNaN(v)) { values.push(childNode) }
                else { values.push(v) }
            } else {
              var gcNames = Object.getOwnPropertyNames(childNode);
              gcNames.forEach(function(name) {
                node[idea.title][name] = childNode[name];
              });
            }
            if (values.length > 0) {
              var i = 1;
              values.forEach(function(value){
                node[idea.title][i] = value;
                i++;
              });
            }
        });
    } 
    return node;
  },
  getValue: function(el) {
    if (Q.models[el.id]){ 
      var idea = Q.models[el.id].getIdea();
      var node = mapBinding.getNode(idea);
      return node;
    } else { return 'Map not found.'; }
  },
  setValue: function(el, value) {
    el.text("");
    Q.models[el.attr('id')] = buildMap(el,value);
  },
  subscribe: function(el, callback){
    var subscribe = function(e) { callback(); }
    Q.models[el.id].addEventListener('layoutChangeComplete', subscribe);
  },
  unsubscribe: function(el) {
    Q.models[el.id].removeEventListener('layoutChangeComplete', mapBinding.subscribe);
  }
});
Shiny.inputBindings.register(mapBinding,'Q.mapBinding');