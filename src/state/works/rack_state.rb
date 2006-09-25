#!/usr/bin/env ruby
# State::Works::RackState -- davaz.com -- 04.07.2006 -- mhuggler@ywesee.com

require 'state/art_object'
require 'state/redirect'

module DAVAZ
	module State
		module Works
class RackState < State::Works::Global
	ARTGROUP_ID = nil
	def init
		@model = OpenStruct.new
		serie_id = @session.user_input(:serie_id) 
		series = @session.app.load_series_by_artgroup(artgroup_id)
		@model.series = series
		if(serie_id.nil?)
			unless(series.empty?)
				serie_id = series.first.serie_id
			end
		end
		@model.serie_id = serie_id
		args = [ 
			[ :artgroup_id, artgroup_id], 
			[ :serie_id, serie_id], 
		]
		url = @session.lookandfeel.event_url(:gallery, :ajax_rack, 
																				 args) 
		@model.serie_items = {
			'artObjectIds'	=>	[],
			'images'	=>	[],
			'titles'	=>	[],
			'dataUrl'	=>	url,
			'serieId'	=>	serie_id,
		}
		serie = @session.app.load_serie(serie_id)
		unless(serie.nil?)
			serie_items = serie.artobjects
			serie_items.each { |item|
				if(Util::ImageHelper.has_image?(item.artobject_id))
					image = Util::ImageHelper.image_path(item.artobject_id, 'slideshow')
					@model.serie_items['artObjectIds'].push(item.artobject_id)
					@model.serie_items['images'].push(image)
					@model.serie_items['titles'].push(item.title)
				end
			}
		end
	end
	def artgroup_id
		self.class.const_get(:ARTGROUP_ID)
	end
end
class AjaxRackUploadImage < SBSM::State
	include Magick
	VIEW = View::ImageDiv
	VOLATILE = true
	def init 
		string_io = @session.user_input(:image_file)
		unless(string_io.nil?)
			artobject_id = @session.user_input(:artobject_id) 
			if artobject_id
				Util::ImageHelper.store_upload_image(string_io, 
																						 artobject_id)
				@model = OpenStruct.new
				@model.artobject = @session.app.load_artobject(artobject_id)
			else
				img_name = Time.now.to_i.to_s 
				image = Image.from_blob(string_io.read).first
				extension = image.format.downcase
				path = File.join(
					DAVAZ::Util::ImageHelper.abs_tmp_path,
					img_name + "." + extension
				)
				image.write(path)
				@model.artobject.abs_tmp_image_path = path
			end
		end
	end
end
class AdminRackState < State::Works::RackState
	include AdminArtObjectMethods
	def ajax_upload_image
		AjaxRackUploadImage.new(@session, @model)
	end
	def delete
		artobject_id = @session.user_input(:artobject_id)
		@session.app.delete_artobject(artobject_id)
		model = self.request_path
		if(fragment = @session.user_input(:fragment))
			model << "##{fragment}" unless fragment.empty?
		end
		newstate = State::Redirect.new(@session, model)
	end
	def update
		artobject_id = @session.user_input(:artobject_id)
		@model.artobject = @session.app.load_artobject(artobject_id)
		mandatory = []
		keys = [
			:title,
			:artgroup_id,
			:serie_id,
			:serie_position,
			:tool_id,
			:material_id,
			:date,
			:country_id,
			:tags_to_s,
			:location,
			:form_language,
			:price,
			:size,
			:text,
			:url,
		].concat(mandatory)
		update_hash = {}
		user_input(keys, mandatory).each { |key, value|
			if(match = key.to_s.match(/(form_)(.*)/))
				update_hash.store(match[2].intern, value)
			elsif(key == :tags_to_s)
				if(value.nil?)
					update_hash.store(:tags, [])	
				else
					update_hash.store(:tags, value.split(','))	
				end
			elsif(key == :date)
				update_hash.store(:date, "#{value.year}-#{value.month}-#{value.day}")
			else
				update_hash.store(key, value)
			end	
		}
		unless(error?)
			if(artobject_id)
				@session.app.update_artobject(artobject_id, update_hash)
				model = self.request_path
				if(fragment = @session.user_input(:fragment))
					model << "##{fragment}" unless fragment.empty?
				end
				newstate = State::Redirect.new(@session, model)
			else
				insert_id = @session.app.insert_artobject(update_hash)
				image_path = @model.artobject.abs_tmp_image_path
				Util::ImageHelper.store_tmp_image(image_path, insert_id)
				self 
			end
		else
			update_hash.each { |key, value|
				method = (key.to_s + "=").intern
				@model.artobject.send(method, value)
			}
			@session.app.update_artobject(artobject_id, update_hash)
			@model.artobject = @session.app.load_artobject(artobject_id)
			build_selections
			model = self.request_path
			if(fragment = @session.user_input(:fragment))
				model << "##{fragment}" unless fragment.empty?
			end
			newstate = State::Redirect.new(@session, model)
		end
	end
end
		end
	end
end
