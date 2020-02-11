
#$ = require('jquery')

class Credit

  module.exports = Credit
  Credit.Cards   = require( 'data/cards.json' )

  @AmericanExpressFormat = "/(\d{1,4})(\d{1,6})?(\d{1,5})?/"
  @DinersClubFormat      = "/(\d{1,4})(\d{1,6})?(\d{1,4})?/"
  @Unknown =  { type:"Unknown", patterns:[], format:"defaultFormat", length:[16], cvcLength:[], luhn:true }

  constructor:( @selector ) ->
    @maskedNumber = 'XdDmMyY9'
    @maskedLetter = '_'

  cardFromNumber:(num) ->
    num = (num + '').replace(/\D/g, '')
    for card in Credit.Cards
      for pattern in card.patterns
        p = pattern + ''
        return card if num.substr(0, p.length) == p
    Credit.Unknown

  cardFromType:(type) ->
    return card for card in Credit.Cards when card.type is type

  ready:() ->
    @maskedInputs = document.querySelectorAll( @selector )
    #@setUpMasks( @maskedInputs )
    # Repopulating. Needed b/c static node list was created above.
    @activateMasking( @maskedInputs )
    return

  setUpMasks: (inputs) ->
    i = undefined
    l = inputs.length
    i = 0
    while i < l
      @createShell(  inputs[i] )
      i++
    return

  createShell: (input) ->
    text = ''
    placeholder = input.getAttribute('placeholder')
    input.setAttribute 'maxlength', placeholder.length
    input.setAttribute 'data-placeholder', placeholder
    input.removeAttribute 'placeholder'
    text = '<span class="shell">' + '<span aria-hidden="true" id="' + input.id + 'Mask"><i></i>' + placeholder + '</span>' + input.outerHTML + '</span>'
    input.outerHTML = text
    return

  setValueOfMask: (e) ->
    value = e.target.value
    placeholder = e.target.getAttribute('data-placeholder')
    '<i>' + value + '</i>' + placeholder.substr(value.length)

  activateMasking: (inputs) ->
    i = undefined
    l = undefined
    i = 0
    l = inputs.length
    while i < l
      if @maskedInputs[i].addEventListener?  # remove "if" after death of IE 8
         @maskedInputs[i].addEventListener( 'keyup', ( (e) -> @handleValueChange(e) ), false )
      else if @maskedInputs[i].attachEvent # For IE 8
        @maskedInputs[i].attachEvent( 'onkeyup', (e) -> e.target = e.srcElement; @handleValueChange(e) )
      i++
    return

  handleValueChange: (e) ->
    id = e.target.getAttribute('id')
    switch e.keyCode # allows navigating thru input caplocks control option shift arrow keys
        when 20, 17, 18, 16, 37, 38, 39, 40, 9 then return
    document.getElementById(id).value = @handleCurrentValue(e)
    document.getElementById(id + 'Mask').innerHTML = @setValueOfMask(e)
    return

  handleCurrentValue: (e) ->
    isCharsetPresent = e.target.getAttribute('data-charset')
    placeholder = isCharsetPresent or e.target.getAttribute('data-placeholder')
    value = e.target.value
    l = placeholder.length
    newValue = ''
    i = undefined
    j = undefined
    isInt = undefined
    isLetter = undefined
    strippedValue = undefined
    # strip special characters
    strippedValue = if isCharsetPresent then value.replace(/\W/g, '') else value.replace(/\D/g, '')
    i = 0
    j = 0
    while i < l
      #x = isInt = !isNaN(parseInt(strippedValue[j]))
      isLetter = if strippedValue[j] then strippedValue[j].match(/[A-Z]/i) else false
      matchesNumber = @maskedNumber.indexOf(placeholder[i]) >= 0
      matchesLetter = @maskedLetter.indexOf(placeholder[i]) >= 0
      if matchesNumber and isInt or isCharsetPresent and matchesLetter and isLetter
        newValue += strippedValue[j++]
      else if !isCharsetPresent and !isInt and matchesNumber or isCharsetPresent and (matchesLetter and !isLetter or matchesNumber and !isInt)
        # masking.errorOnKeyEntry(); // write your own error handling function
        return newValue
      else
        newValue += placeholder[i]
        # break if no characters left and the pattern is non-special character
      if strippedValue[j] == undefined
        break
      i++
    if e.target.getAttribute('data-valid-example')
      return @validateProgress(e, newValue)
    newValue

  validateProgress: (e, value) ->
    validExample = e.target.getAttribute('data-valid-example')
    pattern = new RegExp(e.target.getAttribute('pattern'))
    placeholder = e.target.getAttribute('data-placeholder')
    l = value.length
    testValue = ''
    #convert to months
    if l == 1 and placeholder.toUpperCase().substr(0, 2) == 'MM'
      if value > 1 and value < 10
        value = '0' + value
      return value
    # test the value, removing the last character, until what you have is a submatch
    i = l
    while i >= 0
      testValue = value + validExample.substr(value.length)
      if pattern.test(testValue)
        return value
      else
        value = value.substr(0, value.length - 1)
      i--
    value

  errorOnKeyEntry: ->
    # Write your own error handling
    return
