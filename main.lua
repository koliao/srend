function srend_color(r, g, b, a)
    if(a == nil) then
        return {r = r, g = g, b = b, a = 1}
    else
        return {r = r, g = g, b = b, a = a}
    end
end

function srend_color_eq(c1, c2)
    return (c1.r == c2.r and c1.g == c2.g and c1.b == c2.b and c1.a == c2.a)
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

function srend_create_canvas(width, height)
    local canvas = {}

    for y = 1, height do
        table.insert(canvas, {})

        for x = 1, width do
            table.insert(canvas[y], srend_color(0, 0, 0, 0))
        end
    end

    return canvas
end

function srend_draw_pixel(canvas, x, y, color)
    -- Bounds check
    if(y < 0 or y >= #canvas or x < 0 or x >= #canvas[1]) then
        return
    end

    -- TODO: add blend modes
    if(color.a == 1) then
        canvas[y + 1][x + 1].r = color.r
        canvas[y + 1][x + 1].g = color.g
        canvas[y + 1][x + 1].b = color.b
        canvas[y + 1][x + 1].a = color.a
    end
end

function srend_clear_pixels(canvas, color)
    for y, row in pairs(canvas) do
        for x, pixel in pairs(row) do
            srend_draw_pixel(canvas, x - 1, y - 1, color)
        end
    end
end

function srend_draw_rect(canvas, x, y, width, height, color)
    assert(type(x) == "number", "Provide a x value")
    assert(type(y) == "number", "Provide a y value")
    assert(type(width) == "number", "Provide a width value")
    assert(type(height) == "number", "Provide a height value")

    for xx = x, width do
        for yy = y, height do
            srend_draw_pixel(canvas, xx, yy, color)
        end
    end
end

function srend_draw_line(canvas, v1, v2, color)
    local target_line = srend_v2_sub(v2, v1)
    local length = srend_v2_length(target_line)
    local dir = srend_v2_normalize(target_line)

    for t = 0, length do
        local traveled_distance = srend_v2_scale(dir, t)
        local target_pixel = srend_v2_add(v1, traveled_distance)
        srend_draw_pixel(canvas, math.floor(target_pixel.x), math.floor(target_pixel.y), color)
    end
end

function srend_draw_triangle(canvas, v1, v2, v3, color)
    local min_x = math.min(math.min(v1.x, v2.x), v3.x)
    local min_y = math.min(math.min(v1.y, v2.y), v3.y)
    local max_x = math.max(math.max(v1.x, v2.x), v3.x) + 1
    local max_y = math.max(math.max(v1.y, v2.y), v3.y) + 1
    local tmp_width  = math.abs(max_x - min_x)
    local tmp_height = math.abs(max_y - min_y)

    -- Map to tmp canvas origin
    local tmp_canvas = srend_create_canvas(tmp_width, tmp_height)
    local offset_v1 = srend_v2_sub(v1, srend_v2(min_x, min_y))
    local offset_v2 = srend_v2_sub(v2, srend_v2(min_x, min_y))
    local offset_v3 = srend_v2_sub(v3, srend_v2(min_x, min_y))

    -- Draw triangle in tmp canvas
    srend_draw_line(tmp_canvas, offset_v1, offset_v2, color)
    srend_draw_line(tmp_canvas, offset_v2, offset_v3, color)
    srend_draw_line(tmp_canvas, offset_v3, offset_v1, color)

    -- Line fill
    for y, row in pairs(tmp_canvas) do
        local entered_triangle = false
        local inside_triangle = false
        local left_x  = nil
        local right_x = nil

        for x, pixel in pairs(row) do
            if(srend_color_eq(pixel, color)) then -- TODO: what if color is black?
                if(not left_x) then
                    left_x = x
                else
                    right_x = x
                end
            end
        end

        if(left_x and right_x) then
            for x, pixel in pairs(row) do
                local inside_triangle = x >= left_x and x <= right_x
                if(inside_triangle) then
                    srend_draw_pixel(tmp_canvas, x - 1, y - 1, color)
                end
            end
        end
    end

    -- Draw final triangle to original canvas
    for y, row in pairs(tmp_canvas) do
        for x, pixel in pairs(row) do
            srend_draw_pixel(canvas, x - 1 + min_x, y - 1 + min_y, pixel)
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

    canvas = srend_create_canvas(WIDTH, HEIGHT)

    image_data = love.image.newImageData(WIDTH, HEIGHT) 
    image = love.graphics.newImage(image_data)
end

function srend_update_pixels(canvas)
    local map_function = function(x, y, r, g, b, a)
        local color = canvas[y + 1][x + 1]

        return color.r, color.g, color.b, 1
    end

    image_data:mapPixel(map_function)
    image:replacePixels(image_data)
end

function love.draw()
    -- Update pixels
    srend_clear_pixels(canvas, srend_color(0, 0, 0))
    --srend_draw_rect(20, 30, 200, 100, srend_color(1.0, 0.0, 0))
    srend_draw_line(canvas, srend_v2(0, 0), srend_v2(WIDTH-1, HEIGHT-1), srend_color(1, 0, 0))
    srend_draw_line(canvas, srend_v2(10, 20), srend_v2(300, 200), srend_color(1, 0, 0))
    srend_draw_triangle(
        canvas,
        srend_v2(100, 400),
        srend_v2(200, 200),
        srend_v2(300, 400),
        srend_color(0.8, 1, 0)
    )
    srend_draw_triangle(
        canvas,
        srend_v2(500, 100),
        srend_v2(500, 400),
        srend_v2(600, 400),
        srend_color(1, 0, 0)
    )
    srend_draw_triangle(
        canvas,
        srend_v2(300, 300),
        srend_v2(400, 100),
        srend_v2(600, 600),
        srend_color(0, 1, 0)
    )

    -- Draw pixels
    srend_update_pixels(canvas)
    love.graphics.draw(image, 0, 0)
end