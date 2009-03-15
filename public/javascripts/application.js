// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// (10).rnd() => returns random number from 1 to 10
Number.prototype.rnd = function(){
	return Math.floor(Math.random()*this+1)
}

replace_ids = function(s){
  // Random id with timestamp and counter for positions preserving
  window['new_id_counter'] = window['new_id_counter'] || 0
  var new_id = new Date().getTime() + (new_id_counter++);
  return s.replace(/NEW_RECORD/g, new_id);
}

var myrules = {
  '.remove': function(e){
    el = Event.findElement(e);
    target = el.href.replace(/.*#/, '.')
    el.up(target).hide();
    if(hidden_input = el.previous("input[type=hidden]")) hidden_input.value = '1'
  },
  '.add_nested_item': function(e){
    el = Event.findElement(e);
    template = eval(el.href.replace(/.*#/, ''))
    $(el.rel).insert({     
      bottom: replace_ids(template)
    });
  },
  '.add_nested_item_lvl2': function(e){
    el = Event.findElement(e);
    elements = el.rel.match(/(\w+)/g)
    parent = '.'+elements[0]
    child = '.'+elements[1]
    
    child_container = el.up(parent).down(child)    
    parent_object_id = el.up(parent).down('input').name.match(/.*\[(\d+)\]/)[1]
    
    template = eval(el.href.replace(/.*#/, ''))

    template = template.replace(/(attributes[_\]\[]+)\d+/g, "$1"+parent_object_id)
    
   // console.log(template)
    child_container.insert({     
      bottom: replace_ids(template)
     });
  }
};

Event.observe(window, 'load', function(){
  $('container').delegate('click', myrules);
});
