export default {
    content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
    theme: {
        extend: {
            animation: {
                'gradient-pulse': 'gradientPulse 1.5s ease-in-out infinite',
            },
            keyframes: {
                gradientPulse: {
                '0%, 100%': {
                    background: 'linear-gradient(to right, #f97316, #ef4444, #b91c1c)', // orange-500 to red-700
                },
                '50%': {
                    background: 'linear-gradient(to right, #fb923c, #f87171, #dc2626)', // lighter variants
                },
                },
            },
        },
    },
    plugins: [],
}
