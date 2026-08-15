local signs = {
  Error = "󰅚 ",
  Warn = "󰀪 ",
  Hint = "󰌶 ",
  Info = "󰋼 ",
}

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type

  vim.fn.sign_define(hl, {
    text = icon,
    texthl = hl,
    numhl = "",
  })
end


-- ============================================================
-- Diagnostic configuration
-- ============================================================

vim.diagnostic.config({
  -- الرسائل مخفية أثناء الكتابة.
  virtual_text = false,

  -- الأيقونات تظهر دائمًا.
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = signs.Error,
      [vim.diagnostic.severity.WARN] = signs.Warn,
      [vim.diagnostic.severity.HINT] = signs.Hint,
      [vim.diagnostic.severity.INFO] = signs.Info,
    },
  },

  -- تحديد مكان الخطأ.
  underline = true,

  -- تحديث الأخطاء أثناء الكتابة.
  update_in_insert = true,

  severity_sort = true,
})


-- ============================================================
-- Insert → Normal
--
-- عند الخروج من الكتابة:
-- أظهر رسالة الخطأ بجانب كل سطر.
-- ============================================================

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    vim.defer_fn(function()
      if vim.fn.mode() ~= "n" then
        return
      end

      vim.diagnostic.config({
        virtual_text = {
          spacing = 2,
          source = "if_many",
          prefix = "●",
        },
      })
    end, 100)
  end,
})


-- ============================================================
-- Normal → Insert
--
-- عند العودة للكتابة:
-- اخفِ رسائل الأخطاء وأبقِ الأيقونات فقط.
-- ============================================================

vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    vim.diagnostic.config({
      virtual_text = false,
    })
  end,
})
