--    ▗▞▀▚▖▄▄▄▄  ▗▞▀▚▖ ▄▄▄ ▗▞▀▜▌█
--    ▐▛▀▀▘█   █ ▐▛▀▀▘█    ▝▚▄▟▌█
--    ▝▚▄▄▖█   █ ▝▚▄▄▖█         █
--  ▗▄▖                         █
-- ▐▌ ▐▌
--  ▝▀▜▌
-- ▐▙▄▞▘
require('vico.general')
require('vico.remap')

-- ▄▄▄▄  █ █  ▐▌  ▄ ▄▄▄▄   ▄▄▄
-- █   █ █ ▀▄▄▞▘  ▄ █   █ ▀▄▄
-- █▄▄▄▀ █        █ █   █ ▄▄▄▀
-- █     █     ▗▄▖█
-- ▀          ▐▌ ▐▌
--             ▝▀▜▌
--            ▐▙▄▞▘

-- Add LSP handler to lze
require('lze').register_handlers(require('lzextras').lsp)

require('vico.plugin')

