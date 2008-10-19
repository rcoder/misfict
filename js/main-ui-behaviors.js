var SERVER_URL = "/ajax/";

function updateLastSentence() {
  $.getJSON(SERVER_URL + 'last', 
    function(data) {
      $("#post-num").html("#" + data.num + ": ");
      $("#post-text").html(data.text);

      $("#post-text").data("num", data.num);

      $("#metadata").show();

      var lastDate = new Date();
      lastDate.setTime(Date.parse(data.ts));
      $("#posted-at").html(lastDate.toDateString());

      var expires = secondsFromNow(24*60*60);

      if ((data.user == $.cookie("id") && lastDate < expires) || $.cookie("locked")) {
        disableInput();
      } else {
        enableInput();
      }
    }
  );

  setTimeout("updateLastSentence()", 10000);
}

function disableInput() {
  $("#interact").hide();
  $("#wait-msg").show();
}

function enableInput() {
  $("#interact").show();
  $("#wait-msg").hide();
}

function secondsFromNow(secs) {
  d = new Date();
  d.setTime(d.getTime() + secs * 1000);
  return d;
}

function lockEditing() {
  expires = secondsFromNow(60*60);
  $.cookie("locked", "1", { expires: expires });
}

function submitLine() {
  var input = $("#next-sentence").val();
  var userId = $.cookie("id");

  var currSeq = $("#post-text").data("num");

  $.post(SERVER_URL + "next", { text: input, user: userId, num: currSeq }, updateLastSentence);

  $("#next-sentence").html("");

  return true;
}

function toggleStory() {
  var storyElem = $("#story-body");

  if (storyElem.is(":visible")) {
    $("#story-link-label").html("show");
    storyElem.hide();
    $("#page-body").show();

  } else {
    if (!$.cookie("locked")) {
      if (!confirm("If you read the story so far, you won't be able to contribute any more " +
                   "lines until someone else does, or an hour passes. Are you sure you want to peek?")) {
        return false;
      }
    }
   
    $("#page-body").hide();
    storyElem.show();
    lockEditing();
    disableInput();

    $("#story-loading").show();

    $.getJSON(SERVER_URL + "story",
      function(data) {
        $.each(data, function() {
          $("<li>" + this.text + "</li>").appendTo("#story-entries");
          $("#story-loading").hide();
        });
      }
    );

    $("#story-link-label").html("hide");
  }
}

$(document).ready(function() {
  // hide the Javascript warning if JS is available
  $("#no-js").hide();

  // hide post metadata until we have something to display
  $("#metadata").hide();

  // check to see if they have a visit cookie
  if (!$.cookie("id")) {
    var ts = (new Date()).getTime();
    var seed = Math.random().toString();
    var id = seed + "." + ts
    $.cookie("id", id, { expires: 30 });
  } else {
    $.cookie("id", $.cookie("id"), { expires: 30 });
  }

  $("#input-form-submit").click(submitLine);

  $("#story-body").hide();
  $("#story-link").click(toggleStory);

  updateLastSentence();
});

