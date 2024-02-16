function srend_color(r, g, b)
    return {r = r, g = g, b = b}
end

function srend_v2(x, y)
    return {x = x, y = y}
end

function srend_v2_add(v1, v2)
    return srend_v2(v1.x + v2.x, v1.y + v2.y)
end

function srend_v2_sub(v1, v2)
    return srend_v2(v1.x - v2.x, v1.y - v2.y)
end

function srend_v2_scale(v, s)
    return srend_v2(v.x * s, v.y * s)
end

function srend_v2_mul(v1, v2)
    return srend_v2(v1.x * v2.x, v1.y * v2.y)
end

function srend_v2_length(v)
    return math.sqrt(v.x*v.x + v.y*v.y)
end

function srend_v2_normalize(v)
    local length = srend_v2_length(v)
    if(length == 0) then
        return srend_v2(0, 0)
    end

    return srend_v2(v.x / length, v.y / length)
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

function srend_draw_line(v1, v2, color)
    local target_line = srend_v2_sub(v2, v1)
    local length = srend_v2_length(target_line)
    local dir = srend_v2_normalize(target_line)

    for t = 0, length do
        local traveled_distance = srend_v2_scale(dir, t)
        local target_pixel = srend_v2_add(v1, traveled_distance)
        srend_draw_pixel(math.floor(target_pixel.x), math.floor(target_pixel.y), color)
    end
end

function srend_draw_triangle(v1, v2, v3, color)
    srend_draw_line(v1, v2, color)
    srend_draw_line(v2, v3, color)
    srend_draw_line(v3, v1, color)
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
    --srend_draw_rect(20, 30, 200, 100, srend_color(1.0, 0.0, 0))
    srend_draw_line(srend_v2(0, 0), srend_v2(WIDTH-1, HEIGHT-1), srend_color(1, 0, 0))
    srend_draw_line(srend_v2(10, 20), srend_v2(300, 200), srend_color(1, 0, 0))
    srend_draw_triangle(
        srend_v2(100, 400),
        srend_v2(200, 200),
        srend_v2(300, 400),
        srend_color(0.8, 1, 0)
    )
    srend_draw_triangle(
        srend_v2(500, 100),
        srend_v2(500, 400),
        srend_v2(600, 400),
        srend_color(1, 0, 0)
    )

    -- Draw pixels
    srend_update_pixels()
    love.graphics.draw(image, 0, 0)
end