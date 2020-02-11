
import Util    from './Util.js'

class Credit


  window.Credit  = Credit

  @defaultFormat = /(\d{1,4})/g
  @UnknownCard   =  { type:'Unknown', pattern: /^U/, format:Credit.defaultFormat, length:[16], cvcLength:[3], luhn:true }

  constructor:() ->
    @delay = 0

  init:( numId, expId, cvcId, typId ) ->

    num = document.getElementById(numId)
    exp = document.getElementById(expId)
    cvc = document.getElementById(cvcId)
    #ub = document.getElementById(subId)
    typ = document.getElementById(typId)


    @cardNumberInput( num )
    @expiryInput(     exp )
    @cvcInput(        cvc )

    #Util.log( 'Credit.init() start', numId, expId, cvcId, subId, typId, resId )

    updateType = (e) =>
      cardType = @parseCardType(e.target.value)
      msg      = if cardType? and cardType isnt '' then cardType else ''
      typ.innerHTML = msg + ' Card Number'
      #Util.log( 'Credit.init() updateType', num.value, exp.value, cvc.value, msg )
      return
    num.addEventListener( 'input', updateType )

    validate = (e) =>
      Util.noop( e )
      card      = @cardFromNumber(num.value )
      expiryObj = @parseCardExpiry(    exp.value )
      $('#er-num').show() if not @validateCardNumber( num.value )
      $('#er-exp').show() if not @validateCardExpiry( expiryObj )
      $('#er-exp').show() if not @validateCardCVC(    cvc.value, card.type )
      return
    Util.noop( validate )
    #sub.addEventListener('click', validate )

    ###
    validateF = (e) =>
      Util.noop( e )
      valid     = []
      expiryObj = @parseCardExpiry( exp.value )
      valid.push( @fieldStatus( num, @validateCardNumber( num.value ) ) )
      valid.push( @fieldStatus( exp, @validateCardExpiry( expiryObj ) ) )
      valid.push( @fieldStatus( cvc, @validateCardCVC( cvc.value, typ.innerHTML ) ) )
      msg = if valid.every(Boolean) then 'valid' else  'invalid'
      res.innerHTML = msg
      Util.log( 'Credit.init() validate', num.value, exp.value, cvc.value, msg )
      return
    #sub.addEventListener('click', validate )
    Util.noop( validateF )
    ###

  fieldStatus:( input, valid ) =>
    if valid
      @removeClass( input.parentNode, 'error' )
    else
      @addClass(    input.parentNode, 'error' )
    valid

  addClass:( elem, klass) ->
    if elem.className.indexOf(klass) is -1
       elem.className += ' ' + klass
    return

  removeClass:( elem, klass ) ->
    if elem.className.indexOf(klass) isnt -1
       elem.className = elem.className.replace( klass, '' )
    return

  cardFromNumber: (num) ->
    num = (num + '').replace(/\D/g, '')
    for card in Credit.cards when card.pattern.test(num)
      return card
    #console.log( 'Credit.cardFromNumber()', num, ven.type )
    Credit.UnknownCard

  cardFromType: (type) ->
    for card in Credit.cards when card.type is type
      return card
    #console.log( 'Credit.cardFromType()', type, ven.type )
    Credit.UnknownCard

  isCard:( card ) ->
    card? and card.type isnt 'Unknown'
    
  getCaretPos: (ele) ->
    if ele.selectionStart?
      return ele.selectionStart


  eventNormalize:( listener ) =>
    return (e = window.event) ->
      e.target = e.target or e.srcElement
      e.which  = e.which  or e.keyCode
      unless e.preventDefault?
        e.preventDefault = -> this.returnValue = false
      listener(e)

  doListen:( ele, event, listener ) ->
    listener = @eventNormalize(listener)
    if ele.addEventListener?
       ele.addEventListener(event, listener, false)
    else
       ele.attachEvent("on#{event}", listener)

  @cards = [
    # Debit cards must come first, since they have more
    # specific patterns than their credit-card equivalents.
    {
      type: 'VisaElectron'
      pattern: /^4(026|17500|405|508|844|91[37])/
      format: Credit.defaultFormat
      length: [16]
      cvcLength: [3]
      luhn: true
    }
    {
      type: 'Maestro'
      pattern: /^(5(018|0[23]|[68])|6(39|7))/
      format: Credit.defaultFormat
      length: [12..19]
      cvcLength: [3]
      luhn: true
    }
    {
      type: 'Forbrugsforeningen'
      pattern: /^600/
      format: Credit.defaultFormat
      length: [16]
      cvcLength: [3]
      luhn: true
    }
    {
      type: 'Dankort'
      pattern: /^5019/
      format: Credit.defaultFormat
      length: [16]
      cvcLength: [3]
      luhn: true
    }
    # Credit cards
    {
      type: 'Visa'
      pattern: /^4/
      format: Credit.defaultFormat
      length: [13, 16]
      cvcLength: [3]
      luhn: true
    }
    {
      type: 'Mastercard'
      pattern: /^(5[1-5]|2[2-7])/
      format: Credit.defaultFormat
      length: [16]
      cvcLength: [3]
      luhn: true
    }
    {
      type: 'Amex'
      pattern: /^3[47]/
      format: /(\d{1,4})(\d{1,6})?(\d{1,5})?/
      length: [15]
      cvcLength: [3..4]
      luhn: true
    }
    {
      type: 'DinersClub'
      pattern: /^3[0689]/
      format: /(\d{1,4})(\d{1,4})?(\d{1,4})?(\d{1,2})?/
      length: [14]
      cvcLength: [3]
      luhn: true
    }
    {
      type: 'Discover'
      pattern: /^6([045]|22)/
      format: Credit.defaultFormat
      length: [16]
      cvcLength: [3]
      luhn: true
    }
    {
      type: 'UnionPay'
      pattern: /^(62|88)/
      format: Credit.defaultFormat
      length: [16..19]
      cvcLength: [3]
      luhn: false
    }
    {
      type: 'JCB'
      pattern: /^35/
      format: Credit.defaultFormat
      length: [16]
      cvcLength: [3]
      luhn: true
    }
  ]

  luhnCheck:(num) ->
    odd = true
    sum = 0

    digits = (num + '').split('').reverse()

    for digit in digits
      digit = parseInt(digit, 10)
      digit *= 2 if (odd = !odd)
      digit -= 9 if digit > 9
      sum += digit

    sum % 10 == 0

  hasTextSelected:(target) ->
    # If some text is selected in IE
    target.selectionStart? and target.selectionStart isnt target.selectionEnd

  # Private

  # Replace Full-Width Chars

  replaceFullWidthChars:( str = '' ) =>
    if not Util.isStr(str) or str is 'keypress'
      Util.trace(  'replaceKeypress', str )
      return ''

    fullWidth = '\uff10\uff11\uff12\uff13\uff14\uff15\uff16\uff17\uff18\uff19'
    halfWidth = '0123456789'

    value = ''
    chars = str.split('')

    for char in chars
      idx  = fullWidth.indexOf(char)
      char = halfWidth[idx] if idx > -1
      value += char

    #console.log( 'replaceFullTwo', { str:str, value:value, chars:chars } )
    value

  # Format Card Number

  reFormatCardNumberIp:(e) =>
    cursor = @getCaretPos(e.target)
    e.target.value = @formatCardNumber(e.target.value)
    if cursor? and e.type isnt 'change'
      e.target.setSelectionRange(cursor, cursor)

  formatCardNumberIp:(e) =>
    # Only format if input is a number
    digit = String.fromCharCode(e.which)
    return unless /^\d+$/.test(digit)

    value  = e.target.value
    card   = @cardFromNumber(value + digit)
    #console.log('Credit.formatCardNumber()', value, card )
    length = (value.replace(/\D/g, '') + digit).length

    upperLength = 16
    upperLength = card.length[card.length.length - 1] if @isCard(card)
    return if length >= upperLength

    # Return if focus isn't at the end of the text
    cursor = @getCaretPos(e.target)
    #console.log( 'Cursor', { value:value, len:value.length, cursor:cursor } )
    return if cursor and cursor isnt value.length

    if @isCard(card) and card.type is 'amex'
      # AMEX cards are formatted differently
      re = /^(\d{4}|\d{4}\s\d{6})$/
    else
      re = /(?:^|\s)(\d{4})$/

    # If '4242' + 4
    if re.test(value)
      e.preventDefault()
      fn  = () -> (e.target.value = "#{value} #{digit}")
      setTimeout( fn, @delay  )

    # If '424' + 2
    else if re.test(value + digit)
      e.preventDefault()
      fn  = () -> (e.target.value = "#{value + digit} ")
      setTimeout( fn, @delay  )

  formatBackCardNumberIp:(e) =>
    value = e.target.value

    # Return unless backspacing
    return unless e.which is 8

    # Return if focus isn't at the end of the text
    cursor = @getCaretPos(e.target)
    return if cursor and cursor isnt value.length

    # Remove the digit + trailing space
    if /\d\s$/.test(value)
      e.preventDefault()
      fn = () -> e.target.value = value.replace( /\d\s$/, '' )
      setTimeout( fn, @delay  )
    # Remove digit if ends in space + digit
    else if /\s\d?$/.test(value)
      e.preventDefault()
      fn = () -> e.target.value = value.replace( /\d$/, '' )
      setTimeout( fn, @delay  )

  # Format Expiry

  reFormatExpiryIp:(e) =>
    cursor = @getCaretPos(e.target)
    e.target.value = @formatCardExpiry(e.target.value)
    if cursor? and e.type isnt 'change'
      e.target.setSelectionRange(cursor, cursor)

  formatCardExpiryIp:(e) =>
    # Only format if input is a number
    digit = String.fromCharCode(e.which)
    return unless /^\d+$/.test(digit)

    val = e.target.value + digit

    if /^\d$/.test(val) and val not in ['0', '1']
      e.preventDefault()
      fn  = () -> e.target.value = "0#{val} / "
      setTimeout( fn, @delay )

    else if /^\d\d$/.test(val)
      e.preventDefault()
      fn  = () -> e.target.value = "#{val} / "
      setTimeout( fn, @delay )

  formatForwardExpiryIp:(e) =>
    digit = String.fromCharCode(e.which)
    return unless /^\d+$/.test(digit)
    val = e.target.value
    if /^\d\d$/.test(val)
      e.target.value = "#{val} / "

  formatForwardSlashAndSpaceIp:(e) =>
    which = String.fromCharCode(e.which)
    return unless which is '/' or which is ' '
    val = e.target.value
    if /^\d$/.test(val) and val isnt '0'
      e.target.value = "0#{val} / "

  formatBackExpiryIp:(e) =>
    value = e.target.value

    # Return unless backspacing
    return unless e.which is 8

    # Return if focus isn't at the end of the text
    cursor = @getCaretPos(e.target)
    return if cursor and cursor isnt value.length

    # Remove the trailing space + last digit
    if /\d\s\/\s$/.test(value)
      e.preventDefault()
      fn = () -> e.target.value = value.replace(/\d\s\/\s$/, '')
      setTimeout( fn, @delay )

  # Format CVC

  reFormatCVCIp:(e) =>
    cursor = @getCaretPos(e.target)
    e.target.value = @replaceFullWidthChars(e.target.value).replace(/\D/g, '')[0...4]
    if cursor? and e.type isnt 'change'
      e.target.setSelectionRange(cursor, cursor)

  # Restrictions

  restrictNumericIp:(e) =>
    # Key event is for a browser shortcut
    return if e.metaKey or e.ctrlKey

    # If keycode is a special char (WebKit)
    return if e.which is 0

    # If char is a special char (Firefox)
    return if e.which < 33

    input = String.fromCharCode(e.which)

    # Char is a number
    unless /^\d+$/.test(input)
      e.preventDefault()

  restrictCardNumberIp:(e) =>
    digit  = String.fromCharCode(e.which)
    return unless /^\d+$/.test(digit)

    return if @hasTextSelected(e.target)

    # Restrict number of digits
    value = (e.target.value + digit).replace(/\D/g, '')
    card  = @cardFromNumber(value)

    if @isCard(card) and value.length > card.length[card.length.length - 1]
      e.preventDefault()
    else if value.length > 16
      e.preventDefault()

  restrictExpiryIp:(e) =>
    digit  = String.fromCharCode(e.which)
    return unless /^\d+$/.test(digit)

    return if @hasTextSelected(e.target)

    value = e.target.value + digit
    value = value.replace(/\D/g, '')

    if value.length > 6
      e.preventDefault()

  restrictCVCIp:(e) =>
    digit  = String.fromCharCode(e.which)
    return unless /^\d+$/.test(digit)
    return if @hasTextSelected(e.target)
    val = e.target.value + digit
    if val.length > 4
      e.preventDefault()

  cvcInput:(input) =>
    @doListen(input, 'keypress', @restrictNumericIp)
    @doListen(input, 'keypress', @restrictCVCIp)
    @doListen(input, 'paste',    @reFormatCVCIp)
    @doListen(input, 'change',   @reFormatCVCIp)
    @doListen(input, 'input',    @reFormatCVCIp)

  expiryInput:(input) =>
    @doListen(input, 'keypress', @restrictNumericIp)
    @doListen(input, 'keypress', @restrictExpiryIp)
    @doListen(input, 'keypress', @formatCardExpiryIp)
    @doListen(input, 'keypress', @formatForwardSlashAndSpaceIp)
    @doListen(input, 'keypress', @formatForwardExpiryIp)
    @doListen(input, 'keydown',  @formatBackExpiryIp)
    @doListen(input, 'change',   @reFormatExpiryIp)
    @doListen(input, 'input',    @reFormatExpiryIp)

  cardNumberInput:(input) =>
    @doListen(input, 'keypress', @restrictNumericIp)
    @doListen(input, 'keypress', @restrictCardNumberIp)
    @doListen(input, 'keypress', @formatCardNumberIp)
    @doListen(input, 'keydown',  @formatBackCardNumberIp)
    @doListen(input, 'paste',    @reFormatCardNumberIp)
    @doListen(input, 'change',   @reFormatCardNumberIp)
    @doListen(input, 'input',    @reFormatCardNumberIp)

  numericInput:(input) =>
    @doListen(input, 'keypress', @restrictNumericIp)
    @doListen(input, 'paste',    @restrictNumericIp)
    @doListen(input, 'change',   @restrictNumericIp)
    @doListen(input, 'input',    @restrictNumericIp)

  # Validations

  parseCardExpiry:(value) =>
    value = value.replace(/\s/g, '')
    [month, year] = value.split('/', 2)

    # Allow for year shortcut
    if year?.length is 2 and /^\d+$/.test(year)
      prefix = (new Date).getFullYear()
      prefix = prefix.toString()[0..1]
      year   = prefix + year

    month = parseInt(month, 10)
    year  = parseInt(year, 10)

    month: month, year: year

  validateCardNumber:(num) =>
    num = (num + '').replace(/\s+|-/g, '')
    return false unless /^\d+$/.test(num)

    card = @cardFromNumber(num)
    return false unless @isCard(card)

    num.length in card.length and
      (card.luhn is false or @luhnCheck(num))

  validateCardExpiry:(month, year) =>
    # Allow passing an object
    if typeof month is 'object' and 'month' of month
      {month, year} = month

    return false unless month and year

    month = String(month).trim()
    year  = String(year).trim()

    return false unless /^\d+$/.test(month)
    return false unless /^\d+$/.test(year)
    return false unless 1 <= month <= 12

    if year.length == 2
      if year < 70
        year = "20#{year}"
      else
        year = "19#{year}"

    return false unless year.length == 4

    expiry      = new Date()
    expiry.setYear(  year  )
    expiry.setMonth( month )
    currentTime = new Date

    # Months start from 0 in JavaScript
    expiry.setMonth(expiry.getMonth() - 1)

    # The cc expires at the end of the month,
    # so we need to make the expiry the first day
    # of the month after
    expiry.setMonth(expiry.getMonth() + 1, 1)

    expiry > currentTime

  validateCardCVC:(cvc, type) =>
    cvc = String(cvc).trim()
    return false unless /^\d+$/.test(cvc)

    card = @cardFromType(type)
    if @isCard(card)
      # Check against a explicit card type
      cvc.length in card.cvcLength
    else
      # Check against all types
      cvc.length >= 3 and cvc.length <= 4

  parseCardType:(num) =>
    return '' unless num
    card = @cardFromNumber(num)
    if @isCard(card) then card.type else ''

  formatCardNumber:(num) =>
    return '' if not Util.isStr(num)
    num  = @replaceFullWidthChars(num)
    num  = num.replace(/\D/g, '')
    card = @cardFromNumber(num)
    #console.log( 'Credit.formatCardNumber()', num, card  )
    return num unless @isCard(card)

    upperLength = card.length[card.length.length - 1]
    num = num[0...upperLength]

    if card.format.global
      num.match(card.format)?.join(' ')
    else
      groups = card.format.exec(num)
      return unless groups?
      groups.shift()
      groups = groups.filter(Boolean)
      groups.join(' ')

  formatCardExpiry:(expiry) =>
    expiry = @replaceFullWidthChars(expiry)
    parts = expiry.match(/^\D*(\d{1,2})(\D+)?(\d{1,4})?/)
    return '' unless parts

    mon = parts[1] || ''
    sep = parts[2] || ''
    year = parts[3] || ''

    if year.length > 0
      sep = ' / '

    else if sep is ' /'
      mon = mon.substring(0, 1)
      sep = ''

    else if mon.length == 2 or sep.length > 0
      sep = ' / '

    else if mon.length == 1 and mon not in ['0', '1']
      mon = "0#{mon}"
      sep = ' / '

    return mon + sep + year

export default Credit