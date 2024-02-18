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

function srend_v2_triangle_area(v1, v2, v3)
    local ab = srend_v2_sub(v2, v1)
    local ac = srend_v2_sub(v3, v1)
    local ab_mag = srend_v2_length(ab)
    local ac_mag = srend_v2_length(ac) 
    local ab_c2 = ab.y > 0 and ab.x < 0
    local ab_c3 = ab.y < 0 and ab.x < 0
    local ab_c4 = ab.y < 0 and ab.x > 0
    local ab_angle = math.atan2(ab.y , ab.x)
    if(ab_c2) then
        ab_angle = ab_angle + math.pi/4
    elseif(ab_c3) then
        ab_angle = ab_angle + 2*math.pi/4
    elseif(ab_c4) then
        ab_angle = ab_angle + 3*math.pi/4
    end
    local ac_c2 = ac.y > 0 and ac.x < 0
    local ac_c3 = ac.y < 0 and ac.x < 0
    local ac_c4 = ac.y < 0 and ac.x > 0
    local ac_angle = math.atan2(ac.y , ac.x)
    if(ac_c2) then
        ac_angle = ac_angle + math.pi/4
    elseif(ac_c3) then
        ac_angle = ac_angle + 2*math.pi/4
    elseif(ac_c4) then
        ac_angle = ac_angle + 3*math.pi/4
    end
    local angle = math.abs(ab_angle - ac_angle)

    return ( ab_mag * ac_mag * math.sin(angle) ) / 2
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
    local fill_mode = "BARYCENTRIC"

    -- Bounding box
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
    if(fill_mode == "LINE_SWEEP") then
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

    elseif(fill_mode == "BARYCENTRIC") then
        local area = srend_v2_triangle_area(v1, v2, v3)

        for y, row in pairs(tmp_canvas) do
            for x, pixel in pairs(row) do
                local pixel = srend_v2(x - 1 + min_x, y - 1 + min_y)
                local a0 = srend_v2_triangle_area(v3, v2, pixel)
                local a1 = srend_v2_triangle_area(v3, v1, pixel)
                local a2 = srend_v2_triangle_area(v1, v2, pixel)

                local alpha = a0 / area
                local beta  = a1 / area
                local gama  = a2 / area

                local c1 = 0 < alpha and alpha < 1
                local c2 = 0 < beta and beta < 1
                local c3 = 0 < gama and gama < 1
                local c4 = alpha + gama + beta <= 1
                local inside_triangle = c1 and c2 and c3 and c4
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
    print(srend_v2_triangle_area(srend_v2(0, 0), srend_v2(10, 10), srend_v2(0, 10)))
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