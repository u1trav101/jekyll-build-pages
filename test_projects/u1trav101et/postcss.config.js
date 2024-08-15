module.exports = {
    plugins: [
      require("autoprefixer"),
      require("stylelint"),
      ...(process.env.JEKYLL_ENV == "production"
        ? [require("cssnano")({ preset: "default" })]
        : [])
    ]
  };