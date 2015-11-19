/**
 * Documentation: http://docs.azk.io/Azkfile.js
 */
// Adds the systems that shape your system
systems({
  'test': {
    // More images:  http://images.azk.io
    image: {"dockerfile": "./Dockerfile"},
    workdir: "/azk/#{manifest.dir}",
    shell: "/bin/sh",
    mounts: {
      '/azk/#{manifest.dir}': path("."),
    },
    envs: {
    },
  },
});
