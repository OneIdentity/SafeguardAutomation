package main

// Importing packages needed by the program
import (
	// Standard library packages
	"context"
	"flag"
	"log"
	"time"

	// Driver to talk to Chrome-based browsers leveraging the
	// Chrome DevTools protocol
	"github.com/chromedp/chromedp"
)

func main() {

	// Command line parameters
	useEdge := flag.Bool("edge", false, "use MS Edge instead of Chrome")
	useIncognito := flag.Bool("incognito", false, "use incognito mode")
	browserInputDelay := flag.Int("delay", 500, "ms to wait before inputs are submitted")

	account := flag.String("account", "", "account")
	password := flag.String("password", "", "password")

	loginUrl := flag.String("url", "", "login URL")
	ignoreCertificateErrors := flag.Bool("insecure", false, "skip certificate validation")

	debug := flag.Bool("debug", false, "enable debug logging")

	flag.Parse()

	// Validating parameters
	if *account == "" {
		log.Fatalln("Account is missing")
	}

	if *password == "" {
		log.Fatalln("Password is missing")
	}

	if *loginUrl == "" {
		log.Fatalln("Login URL is missing")
	}

	// Setting up browser options
	allocOpts := append(
		chromedp.DefaultExecAllocatorOptions[:],
		chromedp.Flag("headless", false),
		chromedp.Flag("enable-automation", false),
		chromedp.Flag("hide-scrollbars", false),
		chromedp.Flag("mute-audio", false),
		chromedp.Flag("disable-infobars", true),
		chromedp.Flag("window-size", "1280,800"),
	)
	if *useEdge {
		allocOpts = append(allocOpts,
			chromedp.ExecPath("C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe"),
		)
	}
	if *useIncognito {
		allocOpts = append(allocOpts,
			chromedp.Flag("incognito", true),
		)
	}
	if *ignoreCertificateErrors {
		allocOpts = append(allocOpts,
			chromedp.Flag("ignore-certificate-errors", true),
		)
	}

	browserOpts := make([]chromedp.ContextOption, 0)
	if *debug {
		browserOpts = append(browserOpts,
			chromedp.WithDebugf(log.Printf),
		)
	}

	// Initializing contexts
	allocCtx, _ := chromedp.NewExecAllocator(context.Background(), allocOpts...)
	runCtx, _ := chromedp.NewContext(allocCtx, browserOpts...)

	// Running login actions
	err := chromedp.Run(runCtx,
		chromedp.Navigate(*loginUrl),
		chromedp.Sleep(time.Millisecond*time.Duration(*browserInputDelay)),
		chromedp.SendKeys("input#local-username", *account, chromedp.ByQuery, chromedp.NodeVisible),
		chromedp.Sleep(time.Millisecond*time.Duration(*browserInputDelay)),
		chromedp.SendKeys("input#local-password", *password, chromedp.ByQuery, chromedp.NodeVisible),
		chromedp.Sleep(time.Millisecond*time.Duration(*browserInputDelay)),
		chromedp.Click("button.flat.primary", chromedp.ByQuery, chromedp.NodeVisible),
	)

	// Wrapping up
	if err != nil {
		log.Fatalln(err)
	} else {
		log.Println("Done")
	}
}
