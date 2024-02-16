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
    srend_update_pixels()
    love.graphics.draw(image, 0, 0)
end