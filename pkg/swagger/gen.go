package swagger

//go:generate rm -rf server
//go:generate mkdir -p server
//go:generate swagger generate server --spec swagger.yml --target server --name trousseaud  --exclude-main
