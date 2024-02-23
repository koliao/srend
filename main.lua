local obj_loader = require "obj_loader"

function load_model(path)
    local object = obj_loader.load(path)

    local mesh = {}
    local s = 100

    for j, f in pairs(object.f) do
        local v1 = object.v[f[1].v]
        local v2 = object.v[f[2].v]
        local v3 = object.v[f[3].v]
        local n = object.vn[j]

        table.insert(mesh, {
            srend_v3(math.floor(s*v1.x), math.floor(s*v1.y), math.floor(s*v1.z)),
            srend_v3(math.floor(s*v2.x), math.floor(s*v2.y), math.floor(s*v2.z)),
            srend_v3(math.floor(s*v3.x), math.floor(s*v3.y), math.floor(s*v3.z)),
            srend_v3(n.x, n.y, n.z)
        } )

        if(#f > 3) then
            local i = 4

            while(i < #f) do
                local pv = object.v[f[i-1].v]
                local cv = object.v[f[i  ].v]

                table.insert(mesh, {
                    srend_v3(math.floor(s*v1.x), math.floor(s*v1.y), math.floor(s*v1.z)),
                    srend_v3(math.floor(s*pv.x), math.floor(s*pv.y), math.floor(s*pv.z)),
                    srend_v3(math.floor(s*cv.x), math.floor(s*cv.y), math.floor(s*cv.z)),
                    srend_v3(n.x, n.y, n.z)
                } )

                i = i + 1
            end
        end
    end

    return mesh
end

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

function srend_lerp(t, a, b)
    return (1-t)*a + t*b
end

function srend_v2(x, y)
    return {x = x, y = y}
end

function srend_v3(x, y, z)
    return {x = x, y = y, z = z}
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

function srend_v3_add(v1, v2)
    return srend_v3(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
end

function srend_v3_sub(v1, v2)
    return srend_v3(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
end

function srend_v3_scale(v, s)
    return srend_v3(v.x * s, v.y * s, v.z * s)
end

function srend_v3_mul(v1, v2)
    return srend_v3(v1.x * v2.x, v1.y * v2.y, v1.z * v2.z)
end

function srend_v3_dot(v1, v2)
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
end

function srend_v3_length(v)
    return math.sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
end

function srend_v3_normalize(v)
    local length = srend_v3_length(v)
    if(length == 0) then
        return srend_v3(0, 0, 0)
    end

    return srend_v3(v.x / length, v.y / length, v.z / length)
end

function srend_v2_triangle_area(v1, v2, v3)
    local ab = srend_v2_sub(v2, v1)
    local ac = srend_v2_sub(v3, v1)

    local ab_mag = srend_v2_length(ab)
    local ac_mag = srend_v2_length(ac) 

    local ab_angle = math.atan2(ab.y, ab.x)
    local ac_angle = math.atan2(ac.y, ac.x)

    local ab_ac_angle = math.abs(ab_angle - ac_angle)
    if(ab_ac_angle > math.pi) then
        ab_ac_angle = 2*math.pi - ab_ac_angle
    end

    return ( ab_mag * ac_mag * math.sin(ab_ac_angle) ) / 2
end

function srend_create_canvas(width, height)
    local canvas = {}
    local z_buffer = {}

    for y = 1, height do
        table.insert(canvas, {})
        table.insert(z_buffer, {})

        for x = 1, width do
            table.insert(canvas[y], srend_color(0, 0, 0, 0))
            table.insert(z_buffer[y], nil)
        end
    end

    return {
        buffer   = canvas,
        z_buffer = z_buffer
    }
end

function srend_draw_pixel(canvas, x, y, color, new_z_value)
    -- Bounds check
    if(y < 0 or y >= #canvas.buffer or x < 0 or x >= #canvas.buffer[1]) then
        return
    end

    -- TODO: add blend modes
    if(color.a == 1) then
        local z_value = canvas.z_buffer[y + 1][x + 1]
        canvas.buffer[y + 1][x + 1].r = color.r
        canvas.buffer[y + 1][x + 1].g = color.g
        canvas.buffer[y + 1][x + 1].b = color.b
        canvas.buffer[y + 1][x + 1].a = color.a
    end
end

function srend_clear_z_buffer(canvas)
    for y, row in pairs(canvas.z_buffer) do
        for x, pixel in pairs(row) do
            row[x] = -1/0
        end
    end
end

function srend_clear_pixels(canvas, color)
    for y, row in pairs(canvas.buffer) do
        for x, pixel in pairs(row) do
            srend_draw_pixel(canvas, x - 1, y - 1, color)
        end
    end

    srend_clear_z_buffer(canvas)
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

function srend_draw_triangle(canvas, v1, v2, v3, color, mode)
    -- mode = "line" | "fill"

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
    if(mode == "fill") then
        if(fill_mode == "LINE_SWEEP") then
            for y, row in pairs(tmp_canvas.buffer) do
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
                            local p = srend_v2(x, y)
                            local d1 = srend_lerp(srend_v2_length(srend_v2_sub(v1, p)), 1, 0)*v1.z
                            local d2 = srend_lerp(srend_v2_length(srend_v2_sub(v2, p)), 1, 0)*v2.z
                            local d3 = srend_lerp(srend_v2_length(srend_v2_sub(v3, p)), 1, 0)*v3.z

                            local z_value = (d1 + d2 + d3) / 3
                            srend_draw_pixel(tmp_canvas, x - 1, y - 1, color, z_value)
                        end
                    end
                end
            end

        elseif(fill_mode == "BARYCENTRIC") then -- TODO: fix
            local area = srend_v2_triangle_area(v1, v2, v3)

            for y, row in pairs(tmp_canvas.buffer) do
                for x, _ in pairs(row) do
                    local point = srend_v2(x - 1 + min_x, y - 1 + min_y)

                    local a1 = srend_v2_triangle_area(point, v2, v3)
                    local a2 = srend_v2_triangle_area(point, v3, v1)
                    local a3 = srend_v2_triangle_area(point, v1, v2)

                    local area_sum = a1 + a2 + a3

                    local error = 0.001
                    local inside_triangle = area_sum <= area + error
                    if(inside_triangle) then
                        srend_draw_pixel(tmp_canvas, x - 1, y - 1, color)
                    end
                end
            end
        end
    end

    -- Draw final triangle to original canvas
    for y, row in pairs(tmp_canvas.buffer) do
        for x, pixel in pairs(row) do
            srend_draw_pixel(canvas, x - 1 + min_x, y - 1 + min_y, pixel)
        end
    end
end

random_colors = {
    srend_color(math.random(), math.random(), math.random()),
    srend_color(math.random(), math.random(), math.random()),
    srend_color(math.random(), math.random(), math.random()),
    srend_color(math.random(), math.random(), math.random()),
    srend_color(math.random(), math.random(), math.random()),
    srend_color(math.random(), math.random(), math.random()),
    srend_color(math.random(), math.random(), math.random()),
    srend_color(math.random(), math.random(), math.random()),
    srend_color(math.random(), math.random(), math.random()),
    srend_color(math.random(), math.random(), math.random()),
    srend_color(math.random(), math.random(), math.random()),
    srend_color(math.random(), math.random(), math.random()),
    srend_color(math.random(), math.random(), math.random()),
    srend_color(math.random(), math.random(), math.random()),
    srend_color(math.random(), math.random(), math.random()),
    srend_color(math.random(), math.random(), math.random()),
    srend_color(math.random(), math.random(), math.random()),
    srend_color(math.random(), math.random(), math.random()),
    srend_color(math.random(), math.random(), math.random()),
    srend_color(math.random(), math.random(), math.random()),
}

function srend_draw_mesh(canvas, mesh, offset_x, offset_y)
    local offset_x = offset_x or 0
    local offset_y = offset_y or 0

    local light_pos = srend_v3(0, 0, 100)

    for i, t in pairs(mesh) do
        -- TODO: use 3D vectors
        local v1 = srend_v3(t[1].x + offset_x, t[1].y + offset_y, t[1].z)
        local v2 = srend_v3(t[2].x + offset_x, t[2].y + offset_y, t[2].z)
        local v3 = srend_v3(t[3].x + offset_x, t[3].y + offset_y, t[3].z)

        local color = random_colors[(i%#random_colors) + 1]
        -- Lambertian
        srend_draw_triangle(canvas, v1, v2, v3, color, "fill")
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

    model = load_model("models/teapot.obj")
end

function srend_update_pixels(canvas)
    local map_function = function(x, y, r, g, b, a)
        local color = canvas.buffer[y + 1][x + 1]

        return color.r, color.g, color.b, 1
    end

    image_data:mapPixel(map_function)
    image:replacePixels(image_data)
end

function love.update(dt)
end

function love.draw()
    -- Update pixels
    srend_clear_pixels(canvas, srend_color(0, 0, 0))

    local cube = {
        -- Face 1
        {
            srend_v3(200, 200, 0),
            srend_v3(300, 100, -100),
            srend_v3(200, 300, 0)
        },
        {
            srend_v3(200, 300, 0),
            srend_v3(300, 100, -100),
            srend_v3(300, 200, -100)
        },

        -- Face 2
        {
            srend_v3(200, 200, 0),
            srend_v3(100, 100, -100),
            srend_v3(200, 300, 0)
        },
        {
            srend_v3(200, 300, 0),
            srend_v3(100, 100, -100),
            srend_v3(100, 200, -100)
        },

        -- Face 3
        {
            srend_v3(200, 200, 0),
            srend_v3(100, 100, -100),
            srend_v3(200, 50, 0)
        },
        {
            srend_v3(200, 200, 0),
            srend_v3(300, 100, -100),
            srend_v3(200, 50, 0)
        }
    }
    srend_draw_mesh(canvas, model, WIDTH/2, HEIGHT/4, "fill")
    -- srend_draw_triangle(
    --     canvas,
    --     srend_v2(100, 400),
    --     srend_v2(300, 200),
    --     srend_v2(500, 400),
    --     srend_color(1, 0, 0),
    --     "fill"
    -- )

    -- Draw pixels
    srend_update_pixels(canvas)

    print( srend_v2_triangle_area(
        srend_v2(-100, -110),
        srend_v2(-80, -100),
        srend_v2(-100, -100)
    ) )
    love.graphics.draw(image, 0, 0)
end
