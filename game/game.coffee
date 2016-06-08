inkjs = require("inkjs")

continueToNextChoice = (s) ->
  while (s.canContinue)
    $("#content").append("<p>#{s.Continue()}</p>")
  if (s.currentChoices.length > 0)
    $("#options").html("")
    for choice in s.currentChoices
      $("#options").append("<li><a href='#' id='choice-#{choice.index}' data-index=#{choice.index}>#{choice.text}</a></li>")
    $("#options li a").click(() ->
      s.ChooseChoiceIndex($(this).data("index"))
      continueToNextChoice(s)
      return false
    )
  else
    $("#content").append("<p>THE END</p>")
    $("#options").html("")

fetch('../fogg.ink.json')
  .then((response) ->
    return response.text()
  )
  .then((data) ->
    s = new inkjs.Story(data)
    continueToNextChoice(s)
  )
