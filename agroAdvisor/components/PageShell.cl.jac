cl {
    def:pub PageShell(props: any) -> any {
        return <main className="w-full px-4 sm:px-6 lg:px-10 py-6 pt-25">
            {props.children}
        </main>;
    }
}