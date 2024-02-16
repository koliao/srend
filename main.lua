function srend_color(r, g, b)
    return {r = r, g = g, b = b}
end

function srend_create_pixels(width, height)
    local pixels = {}

    for y = 1, height do
        table.insert(pixels, {})

        for x = 1, width do
            table.insert(pixels[y], srend_color(1, 0, 0))
        end
    end

    return pixels
end

function srend_draw_pixel(x, y, color)
    pixels[y + 1][x + 1].r = color.r
    pixels[y + 1][x + 1].g = color.g
    pixels[y + 1][x + 1].b = color.b
end

function srend_clear_pixels(color)
    for y, row in pairs(pixels) do
        for x, pixel in pairs(row) do
            srend_draw_pixel(x - 1, y - 1, color)
        end
    end
end

function srend_draw_rect(x, y, width, height, color)
    assert(type(x) == "number", "Provide a x value")
    assert(type(y) == "number", "Provide a y value")
    assert(type(width) == "number", "Provide a width value")
    assert(type(height) == "number", "Provide a height value")

    for xx = x, width do
        for yy = y, height do
            srend_draw_pixel(xx, yy, color)
        end
    end
end

function love.keypressed(key)
    if(key == "escape") then
        love.event.quit(0)
    end
end


function love.load()
    -- Hardcoded width and height
    WIDTH = 800
    HEIGHT = 600

    pixels = srend_create_pixels(WIDTH, HEIGHT)

    image_data = love.image.newImageData(WIDTH, HEIGHT) 
    image = love.graphics.newImage(image_data)
end

function srend_update_pixels()
    local map_function = function(x, y, r, g, b, a)
        local color = pixels[y + 1][x + 1]

        return color.r, color.g, color.b, 1
    end

    image_data:mapPixel(map_function)
    image:replacePixels(image_data)
end

function love.draw()
    -- Update pixels
    srend_clear_pixels(srend_color(0, 0, 0))
    srend_draw_rect(20, 30, 200, 100, srend_color(1.0, 0.0, 0))

    -- Draw pixels
    srend_update_pixels()
    love.graphics.draw(image, 0, 0)
end