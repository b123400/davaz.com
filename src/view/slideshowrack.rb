#!/usr/bin/env ruby
# View::SlideshowRack -- davaz.com -- 03.05.2006 -- mhuggler@ywesee.com

require 'htmlgrid/dojotoolkit'
require 'htmlgrid/divcomposite'
require 'view/serie_widget'
require 'util/image_helper'

module DAVAZ
	module View
		class MultimediaButtonsComposite < HtmlGrid::DivComposite
			CSS_CLASS = 'multimedia-control'
			COMPONENTS = {
				[0,0]	=>	:rack,
				[0,0,1]	=>	:show,
				[0,0,2]	=>	:desk,
			}
			def rack(model)
				img = HtmlGrid::Image.new(:rack, model, @session, self)
				link = HtmlGrid::Link.new(:rack, model, @session, self)
				link.href = "javascript:void(0)"
				link.attributes['onclick'] = "toggleShow('show', null, 'Rack', 'show-wipearea', null);"
				link.value = img
				link
			end
			def show(model)
				img = HtmlGrid::Image.new(:show, model, @session, self)
				link = HtmlGrid::Link.new(:slideshow, model, @session, self)
				link.href = "javascript:void(0)"
				link.attributes['onclick'] = "toggleShow('show',null,'SlideShow','show-wipearea', null);"
				link.value = img
				link
			end
			def desk(model)
				img = HtmlGrid::Image.new(:desk, model, @session, self)
				img
				link = HtmlGrid::Link.new(:desk, model, @session, self)
				link.href = "javascript:void(0)"
				script = "toggleShow('show',null,'Desk','show-wipearea',null);"
				link.set_attribute('onclick', script) 
				link.value = img
				link
			end
		end
		class MultimediaButtons < HtmlGrid::DivComposite
			CSS_CLASS = 'multimedia-buttons'
			COMPONENTS = {
				[0,0,1]	=>	MultimediaButtonsComposite,
			}
		end
		class SlideShowRackComposite < HtmlGrid::DivComposite
			COMPONENTS = {
				[0,0]	=>	component(SerieWidget, :serie_items, 'Rack'),
				#[0,0]	=>	:serie_widget,
				[0,1]	=>	MultimediaButtons,
			}
			CSS_ID_MAP = {
				0	=>	'show-container',
			}
			def serie_widget(model)
				SerieWidget.new('Rack', model, @session, self)
			end
		end
		class GallerySlideShowRackComposite < HtmlGrid::DivComposite
			COMPONENTS = {
				[0,0]	=>	:close_x,
				[0,1] =>	:show, 
				[0,2]	=>	MultimediaButtons,
			}
			CSS_ID_MAP = {
				0	=>	'close-x',
				1	=>	'show-container',
			}
			def close_x(model)
				link = HtmlGrid::Link.new('close', model, @session, self)
				link.href = 'javascript:void(0)'
				link.value = "X"
				script = "replaceDiv('show-wipearea', 'upper-search-composite')"
				link.set_attribute('onclick', script)
				link
			end
			def show(model)
				""
			end
		end
	end
end
