# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
	$.event.props.push 'dataTransfer'
	
	el = $ '#new-image'
	
	el.bind 'dragover', ->
		el.addClass 'hover'
		false
	
	el.bind 'dragend', ->
		el.removeClass 'hover'
		false
		
	el.bind 'dragleave', ->
		el.removeClass 'hover'
		false
			
	el.bind 'drop', (event) ->
		event.stopPropagation()
		event.preventDefault()
		el.addClass('loading').html('...')
			
		files = event.dataTransfer.files
		c = files.length
		
		$.each files, (_, f) ->
			data = new FormData()
			data.append('file', f)
			
			xhr = new XMLHttpRequest()
			xhr.open('POST', '/images');
			xhr.onload = ->
				c--
				if xhr.status == 200
					x = $('<figure><span>new</span><a><img src="/downloads/' + f.fileName + '" alt="" /><figcaption>' + f.fileName + ' <date>just now</date></figcaption></a></figure>').hide()
					x.insertAfter(el)
					x.fadeIn('slow')
				
				el.attr('class', '').html('<a>+</a>') if c == 0
			
			xhr.send(data)
		
		false