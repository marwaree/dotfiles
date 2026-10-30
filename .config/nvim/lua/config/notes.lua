local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local make_entry = require("telescope.make_entry")
local entry_display = require("telescope.pickers.entry_display")

-- TODO: sync git repo when searching notes/tags/... and shortcut for sync and commit/push

-- Search notes
-- stylua: ignore
vim.keymap.set("n", "<leader>nf", function()
  local default_maker = make_entry.gen_from_vimgrep({})

  local displayer = entry_display.create({
    separator = "  ",
    items = {
      { remaining = true },
      { width = 12 },
    },
  })

  builtin.live_grep({
    prompt_title = "Search Note Titles",
    cwd = vim.fn.expand("~/Notes/"),
    follow = true,

    -- Prepend "title: " behind the scenes so the input bar stays clean
    on_input_filter_cb = function(prompt)
      return { prompt = "title: " .. prompt }
    end,

    entry_maker = function(line)
      local entry = default_maker(line)
      if not entry then return nil end

      -- Strip "title:" prefix from the displayed entry text
      local clean_title = entry.text:gsub("^title:%s*", "")
      if clean_title == "" then clean_title = "Untitled" end

      entry.ordinal = clean_title .. " " .. entry.filename

      entry.display = function(e)
        local filename = vim.fs.basename(e.filename)
        return displayer({
          { clean_title },
          { "(" .. filename .. ")", "Comment" },
        })
      end

      return entry
    end,
  })
end)

-- Grep Note Content
vim.keymap.set("n", "<leader>ng", function() builtin.live_grep { prompt_title = "Grep Note Content", cwd = vim.fn.expand("~/Notes/"), follow = true } end)

-- Search backlinks from current note
local function search_backlinks()
    -- Extract 4-letter note ID from the active buffer filename
    local current_path = vim.api.nvim_buf_get_name(0)
    local current_filename = vim.fs.basename(current_path)
    local note_id = current_filename:gsub("%.md$", ""):gsub("%.txt$", "")

    if note_id == "" then
        vim.notify("Current buffer is not a saved note", vim.log.levels.WARN)
        return
    end

    local default_maker = make_entry.gen_from_vimgrep {}

    local displayer = entry_display.create {
        separator = "  ",
        items = {
            { remaining = true }, -- Matching line content
            { width = 12 }, -- Source filename
        },
    }

    builtin.live_grep {
        prompt_title = "Search Backlinks" .. note_id,
        cwd = vim.fn.expand("~/Notes/"),
        follow = true,

        -- Pre-fill prompt with note ID so it remains fully editable
        default_text = note_id,

        entry_maker = function(line)
            local entry = default_maker(line)
            if not entry then return nil end

            -- Ignore self-references from inside the current note
            if vim.fs.basename(entry.filename) == current_filename then return nil end

            local clean_text = vim.trim(entry.text)

            entry.display = function(e)
                local source_file = vim.fs.basename(e.filename)
                return displayer {
                    { clean_text },
                    { "(" .. source_file .. ")", "Comment" },
                }
            end

            return entry
        end,
    }
end

-- Keymap: <leader>nb to search incoming backlinks
vim.keymap.set("n", "<leader>nb", search_backlinks, { desc = "Notes: Search backlinks" })

-- Search tags
local function search_tags()
    local default_maker = make_entry.gen_from_vimgrep {}
    local seen_files = {}

    local displayer = entry_display.create {
        separator = "  ",
        items = {
            { remaining = true },
            { width = 12 },
        },
    }

    local title_cache = {}
    local function get_title(filename)
        if title_cache[filename] then return title_cache[filename] end
        local file = io.open(filename, "r")
        if not file then return "Untitled" end

        for _ = 1, 15 do
            local line = file:read("*line")
            if not line then break end
            local title = line:match("^title:%s*(.-)%s*$")
            if title and title ~= "" then
                file:close()
                title_cache[filename] = title
                return title
            end
        end

        file:close()
        title_cache[filename] = "Untitled"
        return "Untitled"
    end

    local function escape_pcre(str) return str:gsub("([%^%$%.%*%+%?%(%)%[%]%{%}%\\%|%-])", "\\%1") end

    builtin.live_grep {
        prompt_title = "Search Tags",
        cwd = vim.fn.expand("~/Notes/"),
        default_text = "#",
        follow = true,

        additional_args = function() return { "--pcre2", "-U" } end,

        on_input_filter_cb = function(prompt)
            seen_files = {}

            local lookaheads = {}
            for term in prompt:gmatch("%S+") do
                local tag = term:gsub("^#", "")
                if tag ~= "" then
                    local escaped = escape_pcre(tag)
                    -- [^\n]*? ensures it only looks for the tag on the SAME LINE as 'tags:'
                    local tag_regex = "(?:#" .. escaped .. "|tags:[^\\n]*?\\b" .. escaped .. ")"
                    table.insert(lookaheads, "(?=.*" .. tag_regex .. ")")
                end
            end

            local pattern
            if #lookaheads > 0 then
                pattern = "(?is)^" .. table.concat(lookaheads, "")
            else
                -- If only '#' is typed, make sure it matches real tags, NOT Markdown headings (# Heading)
                pattern = "(?is)^(?=.*(?:#[a-zA-Z0-9_]|tags:[^\\n]*?[a-zA-Z0-9_]))"
            end

            return { prompt = pattern }
        end,

        entry_maker = function(line)
            local entry = default_maker(line)
            if not entry then return nil end

            if seen_files[entry.filename] then return nil end
            seen_files[entry.filename] = true

            local clean_title = get_title(entry.filename)
            entry.ordinal = clean_title .. " " .. entry.filename

            entry.display = function(e)
                local source_file = vim.fs.basename(e.filename)
                return displayer {
                    { clean_title },
                    { "(" .. source_file .. ")", "Comment" },
                }
            end

            return entry
        end,
    }
end

vim.keymap.set("n", "<leader>nt", search_tags)

-- New note
local function random_letters(length)
    local chars = "abcdefghijklmnopqrstuvwxyz"
    local result = ""
    for _ = 1, length do
        local rand = math.random(1, #chars)
        result = result .. chars:sub(rand, rand)
    end
    return result
end

vim.keymap.set("n", "<leader>nn", function()
    math.randomseed(os.time() + vim.loop.hrtime())

    local notes_path = vim.fn.expand("~/Notes/")
    local date_str = os.date("%Y-%m-%d %H:%M")
    local filename, path

    -- Collision avoidance loop for unique 4-letter file
    repeat
        filename = random_letters(4)
        path = notes_path .. filename .. ".md"
    until vim.fn.filereadable(path) == 0

    -- Open the new file buffer directly
    vim.cmd("edit " .. path)

    -- Native snippet definition
    -- ${1:Untitled} is the editable target; $1 automatically mirrors it live
    local snippet = table.concat({
        "---",
        "title: ${1:Untitled}",
        "date: " .. date_str,
        "tags: []",
        "---",
        "",
        "# $1",
        "$0",
    }, "\n")

    -- Expand the snippet into the new buffer
    vim.snippet.expand(snippet)
end, { desc = "New Note (Mirrored Title Snippet)" })

-- Function to search notes and insert Markdown [[link]]
local function insert_note_link()
    local default_maker = make_entry.gen_from_vimgrep {}

    local displayer = entry_display.create {
        separator = "  ",
        items = {
            { remaining = true },
            { width = 12 },
        },
    }

    builtin.live_grep {
        prompt_title = "Link Note",
        cwd = vim.fn.expand("~/Notes"),
        follow = true,

        -- Prepend "title: " behind the scenes so search input stays clean
        on_input_filter_cb = function(prompt) return { prompt = "title: " .. prompt } end,

        -- Clean formatting in picker list + store title on entry object
        entry_maker = function(line)
            local entry = default_maker(line)
            if not entry then return nil end

            local clean_title = entry.text:gsub("^title:%s*", "")
            if clean_title == "" then clean_title = "Untitled" end

            -- Save clean title to selection object
            entry.clean_title = clean_title
            entry.ordinal = clean_title .. " " .. entry.filename

            entry.display = function(e)
                local filename = vim.fs.basename(e.filename)
                return displayer {
                    { clean_title },
                    { "(" .. filename .. ")", "Comment" },
                }
            end

            return entry
        end,

        attach_mappings = function(prompt_bufnr, map)
            local function insert_link()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)

                if not selection then return end

                -- Extract 4-letter ID and retrieved frontmatter title
                local filename = vim.fs.basename(selection.filename)
                local note_id = filename:gsub("%.md$", ""):gsub("%.txt$", "")
                local note_title = selection.clean_title or "Untitled"

                -- Construct and insert the [[id|Title]] link at cursor
                local link = "[[" .. note_id .. "|" .. note_title .. "]]"
                vim.api.nvim_put({ link }, "c", true, true)
            end

            map("i", "<CR>", insert_link)
            map("n", "<CR>", insert_link)
            return true
        end,
    }
end

-- Map [[ in insert mode for markdown files
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "text" },
    callback = function()
        vim.keymap.set("i", "[[", function() insert_note_link() end, { buffer = true })
    end,
})

-- Open note link
local function open_note_link()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 1-indexed column position

    -- Search the current line for any [[...]] links
    local start_idx = 1
    while true do
        local s, e, inner = line:find("%[%[(.-)%]%]", start_idx)
        if not s then break end

        -- Check if cursor is currently inside this [[...]] span
        if col >= s and col <= e then
            -- Extract everything before the pipe '|' (or the entire string if no pipe)
            local note_id = inner:match("^([^|]+)")
            if note_id then
                note_id = vim.trim(note_id)
                local path = vim.fn.expand("~/Notes/") .. note_id .. ".md"

                if vim.fn.filereadable(path) == 1 then
                    vim.cmd("edit " .. path)
                else
                    vim.notify("Note not found: " .. note_id .. ".md", vim.log.levels.WARN)
                end
            end
            return
        end

        start_idx = e + 1
    end

    -- Fall back to standard 'gf' behavior if not inside a [[...]] link
    local status, err = pcall(vim.cmd, "normal! gf")
    if not status then vim.notify("No link or file under cursor", vim.log.levels.INFO) end
end

-- Map gf and <CR> in normal mode for Markdown files
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "text" },
    callback = function()
        local opts = { buffer = true, silent = true }
        vim.keymap.set("n", "gf", open_note_link, opts)
        vim.keymap.set("n", "<CR>", open_note_link, opts)
    end,
})
