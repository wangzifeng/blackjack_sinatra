$(document).ready(function(){
    $(document).on("click", "input#player_hit", function(){
    $.ajax({
      type: "POST",
      url: "/playerhand",
    }).done(function(msg){
      $("#game").replaceWith(msg);
    });
    return false;
  });
});

