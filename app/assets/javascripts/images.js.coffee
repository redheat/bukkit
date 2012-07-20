# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
	$.event.props.push 'dataTransfer'
	
	image_template = '''
	<figure>
		<span>new</span>
		<a href="/images/#{id}"><img src="/downloads/#{fileName}" alt="" />
			<figcaption>#{fileName} <date>just now</date></figcaption>
		</a>
	</figure>
	'''
	
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
		el.addClass('loading').html('…')
			
		files = event.dataTransfer.files
		c = files.length
		
		# ideally this would upload all files in one go
		$.each files, (_, f) ->
			data = new FormData
			data.append 'file', f
			
			xhr = new XMLHttpRequest
			xhr.open 'POST', '/images.json'
			
			xhr.onload = ->
				if xhr.status == 201
					json = $.parseJSON(xhr.responseText)
					x = $(image_template.replace(/#{fileName}/g, json.name).replace(/#{id}/, json.id))
					x.hide()
					x.insertAfter el
					x.fadeIn 'slow'
				
				el.attr('class', '').html('<a>+</a>') if c == 1
				c--
			
			xhr.send data
		
		false
		
	$('.edit_name').each (i, el) ->
		el = $(el)
		id = $(el).attr 'data-id'
		
		el.bind 'click', () ->
			false
			
		el.bind 'blur', (event) ->
			# console.log('saving', el, el.text().replace(/\n/g, ''))
			$.ajax("/images/#{id}.json", {
				type: 'put',
				data: { 'image[name]': el.text().replace(/\n/g, '') }
			}).done(() ->
				el.blur().attr('contenteditable', null)
			)
	false
	
	