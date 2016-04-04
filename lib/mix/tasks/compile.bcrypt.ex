defmodule Mix.Tasks.Compile.Bcrypt do
  use Mix.Task

  @shortdoc "Compiles Comeonin"

  def run(_) do
    File.rm_rf!("priv")
    File.mkdir("priv")
    {exec, args} = case :os.type do
      {:win32, _} ->
        {"nmake", ["/F", "Makefile.win", "priv\\bcrypt_nif.dll"]}
      {:unix, os} when os in [:freebsd, :openbsd] ->
        {"gmake", ["priv/bcrypt_nif.so"]}
      _ ->
        {"make", ["priv/bcrypt_nif.so"]}
    end

    if System.find_executable(exec) do
      build(exec, args)
      Mix.Project.build_structure
      :ok
    else
      nocompiler_error(exec)
    end
  end

  def build(exec, args) do
    {result, error_code} = System.cmd(exec, args, stderr_to_stdout: true)
    IO.binwrite result
    if error_code != 0, do: build_error(exec)
  end

  defp nocompiler_error("nmake") do
    raise Mix.Error, message: nocompiler_message("nmake") <> windows_message
  end
  defp nocompiler_error(exec) do
    raise Mix.Error, message: nocompiler_message(exec) <> nix_message
  end

  defp build_error("nmake") do
    raise Mix.Error, message: build_message <> windows_message
  end
  defp build_error(_) do
    raise Mix.Error, message: build_message <> nix_message
  end

  defp nocompiler_message(exec) do
    """
    Could not find the program `#{exec}`.

    You will need to install the C compiler `#{exec}` to be able to build
    Comeonin.

    """
  end

  defp build_message do
    """
    Could not compile Comeonin.

    Please make sure that you are using Erlang / OTP version 18.0 or later
    and that you have a C compiler installed.

    """
  end

  defp windows_message do
    """
    One option is to install a recent version of Visual Studio (you can download
    the community edition for free). When you install Visual Studio, make sure
    you also install the C / C++ tools.

    After installing VS, look in the `Program Files (x86)` folder and search
    for `Microsoft Visual Studio`. Note down the full path of the folder with
    the highest version number.

    Open the `run` command and type in the following command (make sure that
    the path and version number are correct):

    `cmd /K "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" amd64`

    This should open up a command prompt with the necessary environment variables set,
    and from which you will be able to run the commands `mix compile`, `mix deps.compile`
    and `mix test`.

    See https://github.com/elixircnx/comeonin/wiki/Requirements for more
    information.
    """
  end

  defp nix_message do
    """
    Please follow the directions below for the operating system you are
    using:

    Mac OS X: You need to have gcc and make installed. Try running the
    commands `gcc --version` and / or `make --version`. If these programs
    are not installed, you will be prompted to install them.

    Linux: You need to have gcc and make installed. If you are using
    Ubuntu or any other Debian-based system, install the packages
    `build-essential`. Also install `erlang-dev` package if not
    included in your Erlang/OTP version.

    See https://github.com/elixircnx/comeonin/wiki/Requirements for more
    information.
    """
  end
end
