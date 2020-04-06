use Mix.Config

config :git_hooks,
  hooks: [
    pre_commit: [
      verbose: true,
      mix_tasks: [
        "format --check-formatted --dry-run --check-equivalent"
      ]
    ],
    pre_push: [
      verbose: true,
      mix_tasks: [
        "clean",
        "compile --warnings-as-errors",
        "credo --strict",
        "dialyzer --halt-exit-status"
      ]
    ]
  ]
