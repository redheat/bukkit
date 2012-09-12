# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


document.createElement(el) for el in ['header', 'footer', 'article', 'section']

debounce = (func, threshold, execAsap) ->
    timeout = false
    
    return debounced = ->
      obj = this
      args = arguments
      
      delayed = ->
        func.apply(obj, args) unless execAsap
        timeout = null
      
      if timeout
        clearTimeout(timeout)
      else if (execAsap)
        func.apply(obj, args)
      
      timeout = setTimeout delayed, threshold || 250
  
  # Smartscroll
  jQuery.fn['smartscroll'] = (fn) ->
    if fn then this.bind('scroll', debounce(fn)) else this.trigger('smartscroll')


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
			
		el.bind 'keypress', (event) ->
			if event.keyCode == 13
				event.stopPropagation()
				event.preventDefault()
				
				el.trigger 'blur'
				return false
			true
			
		el.bind 'blur', (event) ->
			text = el.text().replace(/\n/g, '').replace(/\s/g, '-')
			$.ajax({
				url: "/images/#{id}.json",
				type: 'PUT',
				data: { 'image[name]': text }
			}).done((data) ->
				# console.log el
				el.text(html).blur()
				el.closest('figure').hide().fadeIn 'slow'
			)
			
		return $(el)

	rows = {};
	$('img[data-src]').each (i, image) ->
		top = Math.round($(image).offset().top)
		rows[top] = [] if !rows[top]
		rows[top].push image

	$(window).smartscroll () ->
		# console.log 'scrolled'
		t = $(window).scrollTop()
		limit = Math.round($(window).height() + t)
		
		$.each rows, (i, key) ->
			if (i <= limit)
				$.each key, (j, el) ->
					if $(el).attr('src') == '/blank.gif'
						# console.log 'Loading', el
						$(el).attr('src', $(el).attr('data-src'))
			
			if (i < (t - 144) or i > limit)
				$.each key, (j, el) ->
					if $(el).attr('src') != '/blank.gif'
						# console.log 'Hiding', el
						$(el).attr('src', '/blank.gif')

	$(window).load () ->
		$(window).scrollTop(1).scrollTop(0) if $(window).scrollTop() == 0

	false
	
	