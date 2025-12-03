cl {
    def PageShell(props: any) -> any {
        return <main className="mx-auto max-w-6xl px-4 py-6">
            {props.children}
        </main>;
    }
}
