# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
	$.event.props.push('dataTransfer')
	
	el = $('#new-image')
	
	el.bind 'dragover', ->
		@className = 'hover'
		return false
	
	el.bind 'dragend', ->
		@className = ''
		return false
		
	el.bind 'dragleave', ->
		@className = ''
		return false
			
	el.bind 'drop', (event) ->
		event.stopPropagation()
		event.preventDefault()
		@className = 'loading'
		@innerHTML = '...'
			
		files = event.dataTransfer.files
		c = files.length
		
		$.each files, (_, f) ->
			data = new FormData()
			data.append('file', f)
			
			xhr = new XMLHttpRequest()
			xhr.open('POST', '/images');
			xhr.onload = ->
				c--
				if (xhr.status == 200)
					x = $('<figure><span>new</span><a><img src="/downloads/' + f.fileName + '" alt="" /><figcaption>' + f.fileName + ' <date>just now</date></figcaption></a></figure>').hide()
					x.insertAfter(el)
					x.fadeIn('slow')
				
				if (c == 0)
					el[0].className = ''
					el[0].innerHTML = '+'
			
			xhr.send(data)
		
		return false