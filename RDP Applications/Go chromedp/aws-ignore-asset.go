package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"time"

	"github.com/chromedp/chromedp"
)

func main() {
	useEdge := flag.Bool("edge", false, "use MS Edge instead of Chrome")
	useIncognito := flag.Bool("incognito", false, "use incognito mode")
	delay := flag.Int("delay", 500, "ms to wait before inputs are submitted")
	rootLogin := flag.Bool("root", false, "root login instead of IAM user")
	account := flag.String("account", "", "account id or alias")
	username := flag.String("username", "", "username")
	password := flag.String("password", "", "password")
	otp := flag.String("otp", "", "OTP")
	asset := flag.String("asset", "", "asset ignored")
	flag.Parse()

	if *rootLogin == false && *account == "" {
		log.Fatalf("Account is missing")
	}

	if *username == "" || *password == "" {
		log.Fatalf("Username or password is missing")
	}

    if *asset != "" {
		
	}

	opts := append(
		chromedp.DefaultExecAllocatorOptions[:],
		chromedp.Flag("headless", false),
		chromedp.Flag("enable-automation", false),
		chromedp.Flag("hide-scrollbars", false),
		chromedp.Flag("mute-audio", false),
		chromedp.Flag("disable-infobars", true),
		chromedp.Flag("ignore-certificate-errors", false),
		chromedp.Flag("window-size", "1280,800"),
	)
	if *useEdge {
		opts = append(opts,
			chromedp.ExecPath("C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe"),
		)
	}
	if *useIncognito {
		opts = append(opts,
			chromedp.Flag("incognito", true),
		)
	}

	allocCtx, _ := chromedp.NewExecAllocator(context.Background(), opts...)
	runCtx, _ := chromedp.NewContext(allocCtx, chromedp.WithLogf(log.Printf))

	var loginUrl string
	if *rootLogin {
		loginUrl = "https://signin.aws.amazon.com/console"
	} else {
		loginUrl = fmt.Sprintf("https://%s.signin.aws.amazon.com/console/", *account)
	}

	loginActions := []chromedp.Action{chromedp.Navigate(loginUrl)}
	if *rootLogin {
		loginActions = append(loginActions,
			chromedp.Click("#root_user_radio_button", chromedp.ByID, chromedp.NodeVisible),
			chromedp.Sleep(time.Millisecond*time.Duration(*delay)),
			chromedp.SendKeys("#resolving_input", *username, chromedp.ByID, chromedp.NodeVisible),
			chromedp.Sleep(time.Millisecond*time.Duration(*delay)),
			chromedp.Click("#next_button", chromedp.ByID, chromedp.NodeVisible),
			chromedp.SendKeys("#ap_password", *password, chromedp.ByID, chromedp.NodeVisible),
			chromedp.Sleep(time.Millisecond*time.Duration(*delay)),
			chromedp.Click("#signInSubmit-input", chromedp.ByID, chromedp.NodeVisible),
		)
	} else {
		loginActions = append(loginActions,
			chromedp.SendKeys("#username", *username, chromedp.ByID, chromedp.NodeVisible),
			chromedp.Sleep(time.Millisecond*time.Duration(*delay)),
			chromedp.SendKeys("#password", *password, chromedp.ByID, chromedp.NodeVisible),
			chromedp.Sleep(time.Millisecond*time.Duration(*delay)),
			chromedp.Click("#signin_button", chromedp.ByID, chromedp.NodeVisible),
		)
	}

	if len(*otp) > 0 {
		if *rootLogin {
			loginActions = append(loginActions,
				chromedp.SendKeys("#ap_tokenCode", *otp, chromedp.ByID, chromedp.NodeVisible),
				chromedp.Sleep(time.Millisecond*time.Duration(*delay)),
				chromedp.Click("#signInSubmit-input", chromedp.ByID, chromedp.NodeVisible),
			)
		} else {
			loginActions = append(loginActions,
				chromedp.SendKeys("#mfacode", *otp, chromedp.ByID, chromedp.NodeVisible),
				chromedp.Sleep(time.Millisecond*time.Duration(*delay)),
				chromedp.Click("#submitMfa_button", chromedp.ByID, chromedp.NodeVisible),
			)
		}
	}

	err := chromedp.Run(runCtx, loginActions...)
	if err != nil {
		log.Fatalln(err)
	}
	log.Println("done")
}
