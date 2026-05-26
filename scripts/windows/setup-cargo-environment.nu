use ./helpers/add-path-env.nu

let cargo_dir = $"($env.USERPROFILE)\\.cargo\\bin"
add-path-env $cargo_dir