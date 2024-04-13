local obj_loader = require "obj_loader"

function generate_ball()
    local radius = 10
    local n = 10

    local mesh = {}

    -- Pole 1
end

function load_model(path)
    local object = obj_loader.load(path)

    local mesh = {}
    local s = 50

    for j, f in pairs(object.f) do
        local v1 = object.v[f[1].v]
        local v2 = object.v[f[2].v]
        local v3 = object.v[f[3].v]
        local n1 = object.vn[f[1].v]
        local n2 = object.vn[f[2].v]
        local n3 = object.vn[f[3].v]

        table.insert(mesh, {
            srend_v3(math.floor(s*v1.x), math.floor(s*v1.y), math.floor(s*v1.z)),
            srend_v3(math.floor(s*v2.x), math.floor(s*v2.y), math.floor(s*v2.z)),
            srend_v3(math.floor(s*v3.x), math.floor(s*v3.y), math.floor(s*v3.z)),
            srend_v3(n1.x, n1.y, n1.z),
            srend_v3(n2.x, n2.y, n2.z),
            srend_v3(n3.x, n3.y, n3.z)
        } )

        if(#f > 3) then
            local i = 4

            while(i < #f) do
                local pv = object.v[f[i-1].v]
                local cv = object.v[f[i  ].v]

                local n1 = object.vn[f[1  ].v]
                local n2 = object.vn[f[i-1].v]
                local n3 = object.vn[f[i  ].v]

                table.insert(mesh, {
                    srend_v3(math.floor(s*v1.x), math.floor(s*v1.y), math.floor(s*v1.z)),
                    srend_v3(math.floor(s*pv.x), math.floor(s*pv.y), math.floor(s*pv.z)),
                    srend_v3(math.floor(s*cv.x), math.floor(s*cv.y), math.floor(s*cv.z)),
                    srend_v3(n1.x, n1.y, n1.z),
                    srend_v3(n2.x, n2.y, n2.z),
                    srend_v3(n3.x, n3.y, n3.z)
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

function srend_color_scale(color, s)
    local r = s*color.r
    local g = s*color.g
    local b = s*color.b

    return srend_color(r, g, b)
end

function srend_color_mix(color_a, color_b)
    local r = color_a.r + color_b.r
    local g = color_a.g + color_b.g
    local b = color_a.b + color_b.b

    return srend_color(r, g, b)
end

function srend_color_add(c1, c2)
    return srend_color(c1.r + c2.r, c1.g + c2.g, c1.b + c2.b)
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

function srend_3x3_matrix(a, b, c, d, e, f, g, h, i)
    if(a) then
        return {
            {a, b, c},
            {d, e, f},
            {g, h, i}
        }
    end

    return {
        {1, 0, 0},
        {0, 1, 0},
        {0, 0, 1}
    }
end

function srend_mat3x3_v3_mul(m, v)
    return srend_v3(
        m[1][1] * v.x + m[1][2] * v.y + m[1][3] * v.z,
        m[2][1] * v.x + m[2][2] * v.y + m[2][3] * v.z,
        m[3][1] * v.x + m[3][2] * v.y + m[3][3] * v.z
    )
end

function srend_mat3x3_mat3x3_mul(m1, m2)
    if(#m1 == 0 or #m2 == 0) then
        return
    end

    return srend_3x3_matrix(
        m1[1][1] * m2[1][1] + m1[1][2] * m2[1][2] + m1[1][3] * m2[1][3],
        m1[1][1] * m2[2][1] + m1[1][2] * m2[2][2] + m1[1][3] * m2[2][3],
        m1[1][1] * m2[3][1] + m1[1][2] * m2[3][2] + m1[1][3] * m2[3][3],

        m1[2][1] * m2[1][1] + m1[2][2] * m2[1][2] + m1[2][3] * m2[1][3],
        m1[2][1] * m2[2][1] + m1[2][2] * m2[2][2] + m1[2][3] * m2[2][3],
        m1[2][1] * m2[3][1] + m1[2][2] * m2[3][2] + m1[2][3] * m2[3][3],

        m1[3][1] * m2[1][1] + m1[3][2] * m2[1][2] + m1[3][3] * m2[1][3],
        m1[3][1] * m2[2][1] + m1[3][2] * m2[2][2] + m1[3][3] * m2[2][3],
        m1[3][1] * m2[3][1] + m1[3][2] * m2[3][2] + m1[3][3] * m2[3][3]
    )
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

function srend_draw_pixel(canvas, x, y, color, new_z_value, nx, ny, nz)
    x = math.floor(x)
    y = math.floor(y)
    -- Bounds check
    if(y < 0 or x < 0 or
        y >= #canvas.buffer or x >= #canvas.buffer[1]
    ) then
        return
    end

    if(not canvas.z_buffer[y + 1]) then
        return
    end

    -- TODO: add blend modes
    if(color.a == 1) then
        local z_value = canvas.z_buffer[y + 1][x + 1]
        if(new_z_value ~= nil) then
            if(z_value == nil or z_value <= new_z_value) then
                if(nx and ny and nz) then
                    local light_dir = srend_v3_normalize(srend_v3(0, y_value, 1))
                    local intensity = srend_v3_dot(srend_v3(nx, ny, nz), light_dir)
                    color = srend_color_scale(color, intensity)
                    color = srend_color_add(color, srend_color(0.2, 0.2, 0.2))
                end

                canvas.buffer[y + 1][x + 1].r = color.r
                canvas.buffer[y + 1][x + 1].g = color.g
                canvas.buffer[y + 1][x + 1].b = color.b
                canvas.buffer[y + 1][x + 1].a = color.a
                canvas.z_buffer[y + 1][x + 1] = new_z_value
            end
        else
            canvas.buffer[y + 1][x + 1].r = color.r
            canvas.buffer[y + 1][x + 1].g = color.g
            canvas.buffer[y + 1][x + 1].b = color.b
            canvas.buffer[y + 1][x + 1].a = color.a
        end
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

function srend_draw_triangle(canvas, v1, v2, v3, color, mode, n1, n2, n3, transform)
        -- local intensity = srend_v3_dot(n1, light_dir)
        -- local color = srend_color_scale(srend_color(1, 1, 1), intensity)
        -- color = srend_color_add(color, srend_color(0.1, 0.1, 0.1))
    -- mode = "line" | "fill"

    local origin = srend_v3(WIDTH/2, HEIGHT/2, 0)
    --local origin = srend_v3(0, 0, 0)

    if(transform) then
        v1 = srend_v3_add(srend_mat3x3_v3_mul(transform, v1), origin)
        v2 = srend_v3_add(srend_mat3x3_v3_mul(transform, v2), origin)
        v3 = srend_v3_add(srend_mat3x3_v3_mul(transform, v3), origin)
    else
        v1 = srend_v3_add(v1, origin)
        v2 = srend_v3_add(v2, origin)
        v3 = srend_v3_add(v3, origin)
    end

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

    -- Line fill
    if(mode == "fill") then
        if(fill_mode == "LINE_SWEEP") then
            -- Draw triangle in tmp canvas
            srend_draw_line(tmp_canvas, offset_v1, offset_v2, color)
            srend_draw_line(tmp_canvas, offset_v2, offset_v3, color)
            srend_draw_line(tmp_canvas, offset_v3, offset_v1, color)
    
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

                    local alpha = a1/area
                    local beta  = a2/area
                    local gama  = a3/area

                    local area_sum = a1 + a2 + a3

                    local error = 0.00001
                    local inside_triangle = area_sum <= area + error

                    -- TODO: use vertex color
                    local v1_color = srend_color(1, 0, 0)
                    local v2_color = srend_color(0, 1, 0)
                    local v3_color = srend_color(0, 0, 1)

                    local alpha_color = srend_color_scale(v1_color, alpha)
                    local beta_color  = srend_color_scale(v2_color, beta)
                    local gama_color  = srend_color_scale(v3_color, gama)
                    local pixel_color = srend_color_mix(alpha_color, beta_color)
                    pixel_color = srend_color_mix(pixel_color, gama_color)

                    local z_value = 0 -- TODO: we are overriding tmp canvas z_buffer
                    if(v1.z) then
                        z_value = alpha*v1.z + beta*v2.z + gama*v3.z
                    end

                    if(inside_triangle) then
                        if(n1 and n2 and n3) then
                            local normal_alpha = srend_v3_scale(n1, alpha)
                            local normal_beta  = srend_v3_scale(n2, beta)
                            local normal_gama  = srend_v3_scale(n3, gama)

                            local normal = srend_v3_add(normal_alpha, normal_beta)
                            normal = srend_v3_normalize(srend_v3_add(normal, normal_gama))

                            srend_draw_pixel(tmp_canvas, x - 1, y - 1, color, z_value, normal.x, normal.y, normal.z)
                        else
                            srend_draw_pixel(tmp_canvas, x - 1, y - 1, pixel_color, z_value)
                        end
                    end
                end
            end
        end
    else
        srend_draw_line(tmp_canvas, offset_v1, offset_v2, color)
        srend_draw_line(tmp_canvas, offset_v2, offset_v3, color)
        srend_draw_line(tmp_canvas, offset_v3, offset_v1, color)
    end

    -- Draw final triangle to original canvas
    for y, row in pairs(tmp_canvas.buffer) do
        for x, pixel in pairs(row) do
            srend_draw_pixel(canvas, x - 1 + min_x, y - 1 + min_y, pixel, tmp_canvas.z_buffer[y][x])
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

function srend_draw_mesh(canvas, mesh, offset_x, offset_y, transform)
    local offset_x = offset_x or 0
    local offset_y = offset_y or 0

    local light_dir = srend_v3_normalize(srend_v3(0, y_value, 1))

    for i, t in pairs(mesh) do
        -- TODO: use 3D vectors
        local v1 = srend_v3(t[1].x + offset_x, t[1].y + offset_y, t[1].z)
        local v2 = srend_v3(t[2].x + offset_x, t[2].y + offset_y, t[2].z)
        local v3 = srend_v3(t[3].x + offset_x, t[3].y + offset_y, t[3].z)
        local n1 = t[4]
        local n2 = t[5]
        local n3 = t[6]
        local random_color = random_colors[(i%#random_colors) + 1]

        local use_random_color = true
        local color = srend_color(1, 1, 1)
        if(use_random_color) then
            color = random_color
        end

        srend_draw_triangle(canvas, v1, v2, v3, color, "fill", n1, n2, n3, transform)
    end
end

function love.keypressed(key)
    if(key == "escape") then
        love.event.quit(0)
    end
    if(key == "up") then
        y_value = math.min(y_value + 0.1, 1)
    end
    if(key == "down") then
        y_value = math.max(y_value - 0.1, -1)
    end

    if(key == "left") then
        z_angle = z_angle + 0.1
        rotation_matrix = srend_3x3_matrix(
            math.cos(z_angle), 0, math.sin(z_angle),
            0, 1, 0,
            math.sin(z_angle), 0, math.cos(z_angle)
        )
    end
    if(key == "right") then
        z_angle = z_angle - 0.1
        rotation_matrix = srend_3x3_matrix(
            math.cos(z_angle), 0, math.sin(z_angle),
            0, 1, 0,
            math.sin(z_angle), 0, math.cos(z_angle)
        )
    end
end

function love.load()
    -- Hardcoded width and height
    WIDTH = 800
    HEIGHT = 600

    love.window.setTitle("Srend")
    canvas = srend_create_canvas(WIDTH, HEIGHT)

    image_data = love.image.newImageData(WIDTH, HEIGHT) 
    image = love.graphics.newImage(image_data)

    z_angle = 0
    rotation_matrix = srend_3x3_matrix(
        1, 0, 0,
        0, 1, 0,
        0, 0, 1
    )
    scale_matrix = srend_3x3_matrix(
        1, 0,   0,
        0,   -1, 0,
        0,   0,   1
    )
    if(true) then
        model = load_model("models/teapot.obj")
    else
        model = {
            -- Front
            {
                srend_v3(-1,  1,  1),
                srend_v3( 1,  1,  1),
                srend_v3( 1, -1,  1)
            },
            {
                srend_v3(-1,  1,  1),
                srend_v3(-1, -1,  1),
                srend_v3( 1, -1,  1)
            },

            -- Back
            {
                srend_v3(-1,  1, -1),
                srend_v3( 1,  1, -1),
                srend_v3( 1, -1, -1)
            },
            {
                srend_v3(-1,  1, -1),
                srend_v3(-1, -1, -1),
                srend_v3( 1, -1, -1)
            },

            -- Left
            {
                srend_v3(-1,  1,  1),
                srend_v3(-1, -1,  1),
                srend_v3(-1, -1, -1)
            },
            {
                srend_v3(-1,  1,  1),
                srend_v3(-1,  1, -1),
                srend_v3(-1, -1, -1)
            },

            -- Right
            {
                srend_v3( 1,  1,  1),
                srend_v3( 1, -1,  1),
                srend_v3( 1, -1, -1)
            },
            {
                srend_v3( 1,  1,  1),
                srend_v3( 1,  1, -1),
                srend_v3( 1, -1, -1)
            },
        }
    end
end

function srend_update_pixels(canvas)
    local map_function = function(x, y, r, g, b, a)
        local color = canvas.buffer[y + 1][x + 1]

        return color.r, color.g, color.b, 1
    end

    image_data:mapPixel(map_function)
    image:replacePixels(image_data)
end

y_value = 0
function love.update(dt)
    z_angle = z_angle + 0.1
    rotation_matrix = srend_3x3_matrix(
        math.cos(z_angle), 0, math.sin(z_angle),
        0, 1, 0,
        math.sin(z_angle), 0, math.cos(z_angle)
    )
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
    local transform = srend_mat3x3_mat3x3_mul(rotation_matrix, scale_matrix)
    srend_draw_mesh(canvas, model, 0, 0, transform)

    -- Draw pixels
    srend_update_pixels(canvas)

    love.graphics.draw(image, 0, 0)
end
