process.stdin.on('data', d => {
  process.stdout.write(d + "\n");
});