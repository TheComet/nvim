return {
    "christoomey/vim-tmux-navigator",
    cmd = {
        "TmuxNavigateLeft",
        "TmuxNavigateDown",
        "TmuxNavigateUp",
        "TmuxNavigateRight",
        "TmuxNavigatePrevious",
    },
    keys = {
        { "<A-h>", "<CMD>TmuxNavigateLeft<CR>" },
        { "<A-l>", "<CMD>TmuxNavigateRight<CR>" },
        { "<A-k>", "<CMD>TmuxNavigateUp<CR>" },
        { "<A-j>", "<CMD>TmuxNavigateDown<CR>" },
    },
}