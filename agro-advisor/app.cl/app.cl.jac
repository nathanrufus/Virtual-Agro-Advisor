cl import from react {useState, useEffect}
cl import "..global.css";

cl {
    def app() -> any {
        return <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
            <h1 className="text-3xl font-bold">Hello, Tailwind!</h1>
            <p className=" text-blue text-center hover:text-yellow bg">My name nathana rufus and im learning jac progarmming</p>
        </div>;
    }
}