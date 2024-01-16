package tests

import (
	"os"
	"os/exec"
	"testing"
)

func TestModifiedTarget(t *testing.T) {
	cmd := exec.Command("make", "test-all")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	err := cmd.Run()
	if err != nil {
		t.Errorf("Failed to run modified target: %v", err)
	}

	if cmd.ProcessState.ExitCode() != 0 {
		t.Errorf("Modified target did not complete successfully")
	}
}
